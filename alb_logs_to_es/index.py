import boto3
import os
import gzip
from datetime import datetime
from botocore.awsrequest import AWSRequest
from botocore.auth import SigV4Auth
from botocore.endpoint import BotocoreHTTPSession
from botocore.credentials import Credentials

def lambda_handler(event, context):
    print('Started')
    es_host = os.environ['ES_HOST']
    es_index = os.environ['ES_INDEX_PREFIX'] + "-" + datetime.strftime(datetime.now(), "%Y%m%d")

    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = event["Records"][0]["s3"]["object"]["key"]

    s3 = boto3.resource('s3')
    s3.Bucket(bucket).download_file(key, '/tmp/log.gz')

    with gzip.open('/tmp/log.gz') as f:
        data = ""

        for line in f:
            data += '{"index":{"_index":"%s","_type":"log"}}\n' % es_index
            data += '{"message":"%s"}\n' % line.strip().replace('"', '\\"')

            if len(data) > 3000000:
                _bulk(es_host, data)
                data = ""

        if data != "":
            _bulk(es_host, data)

    return 'Completed'


def _bulk(host, doc):
    pipeline = os.environ['PIPELINE_NAME']

    url = 'https://%s/_bulk?pipeline=%s' % (host, pipeline)
    headers = {'Content-Type': 'application/x-ndjson'}
    response = request(url, "POST", 'es', headers=headers, data=doc)

    if not response.ok:
        print(response.text)


def request(url, method, service_name, region=None, headers=None, data=None):
    if not region:
        region = os.environ["AWS_REGION"]

    session = boto3.Session()
    credentials = session.get_credentials()

    aws_request = AWSRequest(url=url, method=method, headers=headers, data=data)
    SigV4Auth(credentials, service_name, region).add_auth(aws_request)
    return BotocoreHTTPSession().send(aws_request.prepare())

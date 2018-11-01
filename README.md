# AWS ElasticSearch Kibana Terraform Project

## Kibana Settings
Execute this query in Dev Tools

```
PUT _ingest/pipeline/alblog
{
  "processors": [{
    "grok": {
      "field": "message",
      "patterns":[ "%{NOTSPACE:type} %{TIMESTAMP_ISO8601:timestamp} %{NOTSPACE:elb} %{IP:clientip}:%{INT:clientport:int} (?:(%{IP:targetip}:?:%{INT:targetport:int})|-) %{NUMBER:request_processing_time:float} %{NUMBER:target_processing_time:float} %{NUMBER:response_processing_time:float} %{INT:elb_status_code:int} %{INT:target_status_code:int} %{INT:received_bytes:int} %{INT:sent_bytes:int} \"(?:%{WORD:verb} %{URIPROTO:proto}://?(?:%{URIHOST:urihost})?(?:%{URIPATH:path}(?:%{URIPARAM:params})?)?(?: HTTP/%{NUMBER:httpversion})?|%{DATA:rawrequest})\" \"%{DATA:agent}\"" ],
      "ignore_missing": true
    }
  },{
    "remove":{
      "field": "message"
    }
  }, {
    "user_agent": {
      "field": "agent",
      "target_field": "user_agent",
      "ignore_failure": true
    }
  }, {
    "remove": {
      "field": "agent",
      "ignore_failure": true
    }
  }]
}
```

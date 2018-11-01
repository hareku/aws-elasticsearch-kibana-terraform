#####################################
# ElasticSearch Settings
#####################################
locals {
  elasticsearch_domain = "api-devicebook-me"
}

resource "aws_iam_service_linked_role" "this" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "this" {
  domain_name           = "${local.elasticsearch_domain}"
  elasticsearch_version = "6.3"

  cluster_config {
    instance_type = "t2.small.elasticsearch"
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  snapshot_options {
    automated_snapshot_start_hour = 18
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:ap-northeast-1:${data.aws_caller_identity.this.account_id}:domain/${local.elasticsearch_domain}/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "${local.my_ip}"
          ]
        }
      }
    }
  ]
}
CONFIG
}

#####################################
# Lambda IAM Settings
#####################################
data "aws_iam_policy_document" "alb_logs_to_es" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "alb_logs_to_es" {
  name               = "AWSS3ToES-Lambda-For-${local.app_name}"
  assume_role_policy = "${data.aws_iam_policy_document.alb_logs_to_es.json}"
}

resource "aws_iam_role_policy_attachment" "alb_logs_to_es__lambda_basic_execution" {
  role       = "${aws_iam_role.alb_logs_to_es.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "alb_logs_to_es__es_request" {
  statement {
    actions = [
      "es:ESHttpPost",
      "es:ESHttpPut",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "alb_logs_to_es__es_request" {
  name   = "ElasticSearchRequestPolicy-For-${local.app_name}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.alb_logs_to_es__es_request.json}"
}

resource "aws_iam_role_policy_attachment" "alb_logs_to_es__es_request" {
  role       = "${aws_iam_role.alb_logs_to_es.name}"
  policy_arn = "${aws_iam_policy.alb_logs_to_es__es_request.arn}"
}

data "aws_iam_policy_document" "alb_logs_to_es__s3" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:GetObject*",
      "s3:GetBucketLocation",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "alb_logs_to_es__s3" {
  name   = "ElasticSearchS3Policy-For-${local.app_name}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.alb_logs_to_es__s3.json}"
}

resource "aws_iam_role_policy_attachment" "alb_logs_to_es__s3" {
  role       = "${aws_iam_role.alb_logs_to_es.name}"
  policy_arn = "${aws_iam_policy.alb_logs_to_es__s3.arn}"
}

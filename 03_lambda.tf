#####################################
# Lambda Settings
#####################################
data "archive_file" "alb_logs_to_es" {
  type        = "zip"
  source_dir  = "alb_logs_to_es"
  output_path = "alb_logs_to_es.zip"
}

resource "aws_lambda_function" "alb_logs_to_es" {
  function_name    = "ALBLogsToElasticSearchFor-${local.app_name}"
  filename         = "${data.archive_file.alb_logs_to_es.output_path}"
  source_code_hash = "${data.archive_file.alb_logs_to_es.output_base64sha256}"
  role             = "${aws_iam_role.alb_logs_to_es.arn}"
  handler          = "index.lambda_handler"
  runtime          = "python2.7"
  timeout          = 10
  publish          = true
  memory_size      = 128

  environment {
    variables = {
      ES_HOST         = "${aws_elasticsearch_domain.this.endpoint}"
      ES_INDEX_PREFIX = "alblog"
      PIPELINE_NAME   = "alblog"
    }
  }
}

#####################################
# S3 Bucket Notification
#####################################
resource "aws_s3_bucket_notification" "alb_logs_to_es" {
  bucket = "${local.aws_s3_bucket_elb_log_id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.alb_logs_to_es.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "alb_logs_to_es" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.alb_logs_to_es.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${local.aws_s3_bucket_elb_log_arn}"
}

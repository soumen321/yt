resource "aws_lambda_function" "notify_lambda" {
  filename         = "${path.module}/lambda.zip"
  function_name    = var.function_name
  role            = var.iam_role_arn
  handler         = var.handler
  runtime         = var.runtime

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.eventbridge_rule_arn
}
resource "aws_cloudwatch_event_rule" "cert_notify_rule" {
  name                = var.rule_name
  description         = "Rule for Octopus certificate notification"
  schedule_expression = "cron(${var.cron_expression})"
  role_arn           = var.iam_role_arn
  
  tags = {
    Environment = "noprod"
  }
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.cert_notify_rule.name
  target_id = "SendToLambda"
  arn       = var.lambda_arn
}
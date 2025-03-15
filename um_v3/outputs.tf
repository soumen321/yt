output "lambda_function_arn" {
  value = module.lambda.lambda_arn
}

output "sns_topic_arn" {
  value = module.sns.topic_arn
}

output "eventbridge_rule_arn" {
  value = module.eventbridge.rule_arn
}
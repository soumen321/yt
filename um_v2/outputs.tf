output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = module.iam.role_arn
}

output "ssm_document_name" {
  description = "Name of the SSM document"
  value       = module.ssm.document_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.lambda_arn
}

output "eventbridge_schedule_arn" {
  description = "ARN of the EventBridge schedule"
  value       = module.eventbridge.schedule_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = module.sns.sns_topic_arn
}
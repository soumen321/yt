output "eventbridge_schedule_arn" {
  description = "ARN of the EventBridge schedule"
  value       = module.eventbridge.schedule_arn
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = module.iam.role_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = module.sns.topic_arn
}
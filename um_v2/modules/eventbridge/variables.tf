variable "schedule_name" {
  description = "Name of the EventBridge schedule"
  type        = string
}

variable "schedule_expression" {
  description = "Cron expression for the schedule"
  type        = string
}

variable "timezone" {
  description = "Timezone for the schedule"
  type        = string
}

variable "lambda_arn" {
  description = "ARN of the Lambda function to be triggered"
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role for EventBridge"
  type        = string
}
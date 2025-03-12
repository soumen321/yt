variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "schedule_name" {
  description = "Name of the EventBridge schedule"
  type        = string
}

variable "schedule_timezone" {
  description = "Timezone for the schedule"
  type        = string
}

variable "schedule_cron" {
  description = "Cron expression for the schedule"
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "ssm_document_name" {
  description = "Name of the SSM document"
  type        = string
}

variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "email_endpoints" {
  description = "List of email endpoints for SNS notifications"
  type        = list(string)
}
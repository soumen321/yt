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

variable "iam_role_arn" {
  description = "ARN of the IAM role"
  type        = string
}

variable "ssm_document_name" {
  description = "Name of the SSM document"
  type        = string
}
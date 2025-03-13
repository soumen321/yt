variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = "clip-noprod-octopus-cert-notify_IAM_role"
}

variable "document_name" {
  description = "Name of the SSM document"
  type        = string
  default     = "clip-noprod-octopus-cert-notify-execute-script"
}

variable "schedule_name" {
  description = "Name of the EventBridge schedule"
  type        = string
  default     = "clip-noprod-octopus-cert-notify-rule"
}

variable "schedule_expression" {
  description = "Cron expression for the schedule"
  type        = string
  default     = "0 6,18 * * ? *"
}

variable "timezone" {
  description = "Timezone for the schedule"
  type        = string
  default     = "Europe/Paris"
}

variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = "clip-noprod-octopus-cert-notify"
}

variable "email_endpoints" {
  description = "List of email endpoints for SNS subscriptions"
  type        = list(string)
  default     = ["pranoy.mukherjee@external.engie.com", "anand.p@external.engie.com", "suva"]
}

# Lambda-specific variables
variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "clip-noprod-octopus-cert-notify-lambda"
}

variable "lambda_handler" {
  description = "Lambda function handler"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "python3.9"
}
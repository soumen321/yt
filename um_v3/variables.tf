variable "aws_region" {
  description = "AWS Region"
  type        = string  
}

variable "aws_profile" {
  description = "AWS Profile"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
 
}

variable "lambda_handler" {
  description = "Lambda handler"
  type        = string
 
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.9"
}

variable "rule_name" {
  description = "EventBridge rule name"
  type        = string
  
}

variable "cron_expression" {
  description = "EventBridge cron expression"
  type        = string
  default     = "0 6,18 * * ? *"
}

variable "sns_topic_name" {
  description = "SNS topic name"
  type        = string
 
}

variable "sns_subscribers" {
  description = "List of email subscribers"
  type        = list(string)
 
}

variable "iam_role_name" {
  description = "IAM role name"
  type        = string
 
}

variable "ssm_document_name" {
  description = "SSM document name"
  type        = string
  
}
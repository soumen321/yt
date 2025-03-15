variable "function_name" {
  type = string
}

variable "handler" {
  type = string
}

variable "runtime" {
  type = string
}

variable "iam_role_arn" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

variable "eventbridge_rule_arn" {
  type = string
  description = "ARN of the EventBridge rule that will trigger this Lambda"
}
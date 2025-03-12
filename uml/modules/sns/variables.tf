variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "email_endpoints" {
  description = "List of email endpoints for SNS notifications"
  type        = list(string)
}
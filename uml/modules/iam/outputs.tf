output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.cert_notify.arn
}
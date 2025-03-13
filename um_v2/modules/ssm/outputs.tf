output "document_name" {
  description = "Name of the SSM document"
  value       = aws_ssm_document.this.name
}
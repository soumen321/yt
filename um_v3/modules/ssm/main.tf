resource "aws_ssm_document" "cert_notify_script" {
  name            = var.document_name
  document_type   = "Command"
  document_format = "JSON"

  content = file("${path.module}/documents/execute_script.json")

  tags = {
    Environment = "noprod"
  }
}
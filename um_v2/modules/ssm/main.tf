resource "aws_ssm_document" "this" {
  name          = var.document_name
  document_type = "Command"
  content       = var.document_content
}


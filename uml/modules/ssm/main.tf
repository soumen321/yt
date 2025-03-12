resource "aws_ssm_document" "cert_notify" {
  name            = var.document_name
  document_type   = "Command"
  document_format = "JSON"

  content = file("${path.module}/ssmdocuments/cert-notify-script.json")
}
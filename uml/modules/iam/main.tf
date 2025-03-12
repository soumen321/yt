resource "aws_iam_role" "cert_notify" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "cert_notify" {
  name = "${var.role_name}-policy"
  role = aws_iam_role.cert_notify.id

  policy = file("${path.module}/permissions/eventbridge-role.json")
}
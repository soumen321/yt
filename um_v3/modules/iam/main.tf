resource "aws_iam_role" "eventbridge_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_policy" {
  name = "${var.role_name}-policy"
  role = aws_iam_role.eventbridge_role.id

  policy = file("${path.module}/permissions/eventbridge_policy.json")
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.role_name}-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.role_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = file("${path.module}/permissions/lambda_policy.json")
}
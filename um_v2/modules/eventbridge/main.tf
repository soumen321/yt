resource "aws_scheduler_schedule" "this" {
  name               = var.schedule_name
  schedule_expression = var.schedule_expression
  schedule_expression_timezone = var.timezone

  target {
    arn      = var.lambda_arn
    role_arn = var.role_arn
  }

  flexible_time_window {
    mode = "OFF"
  }
}


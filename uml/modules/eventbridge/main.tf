resource "aws_scheduler_schedule" "cert_notify" {
  name = var.schedule_name
  
  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.schedule_cron
  schedule_expression_timezone = var.schedule_timezone

  target {
    arn = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:document/${var.ssm_document_name}"
    role_arn = var.iam_role_arn

    # input = jsonencode({
    #   DocumentName = var.ssm_document_name
    #   TargetType = "/aws/ssm"
    # })

       input = jsonencode({
      DocumentName = var.ssm_document_name
      Targets = [
        {
          Key = "tag:component"
          Values = ["um"]
        },
        {
          Key = "tag:application"
          Values = ["octopus"]
        }
      ]
    })
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
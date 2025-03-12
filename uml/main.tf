# Main Terraform configuration file
provider "aws" {
  region = var.aws_region
}

# Import modules
module "eventbridge" {
  source = "./modules/eventbridge"
  
  schedule_name = var.schedule_name
  schedule_timezone = var.schedule_timezone
  schedule_cron = var.schedule_cron
  iam_role_arn = module.iam.role_arn
  ssm_document_name = module.ssm.document_name
}

module "iam" {
  source = "./modules/iam"
  
  role_name = var.role_name
}

module "ssm" {
  source = "./modules/ssm"
  
  document_name = var.ssm_document_name
}

module "sns" {
  source = "./modules/sns"
  
  topic_name = var.sns_topic_name
  email_endpoints = var.email_endpoints
}
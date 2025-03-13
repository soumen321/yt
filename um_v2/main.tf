provider "aws" {
  region = var.aws_region
}

module "iam" {
  source     = "./modules/iam"
  role_name  = var.role_name
  policy_json = file("${path.module}/permissions/clip-noprod-octopus-cert-notify_IAM_role.json")
}

module "ssm" {
  source          = "./modules/ssm"
  document_name   = var.document_name
  document_content = file("${path.module}/ssmdocument/clip-noprod-octopus-cert-notify-execute-script.json")
}

module "lambda" {
  source          = "./modules/lambda"
  function_name   = var.lambda_function_name
  handler         = var.lambda_handler
  runtime         = var.lambda_runtime
  role_arn        = module.iam.role_arn
  document_name   = var.document_name
}

module "eventbridge" {
  source             = "./modules/eventbridge"
  schedule_name      = var.schedule_name
  schedule_expression = var.schedule_expression
  timezone           = var.timezone
  lambda_arn         = module.lambda.lambda_arn
  role_arn           = module.iam.role_arn
}

module "sns" {
  source          = "./modules/sns"
  sns_topic_name  = var.sns_topic_name
  email_endpoints = var.email_endpoints
}
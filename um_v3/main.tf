provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "lambda" {
  source = "./modules/lambda"
  
  function_name      = var.lambda_function_name
  handler           = var.lambda_handler
  runtime           = var.lambda_runtime
  sns_topic_arn     = module.sns.topic_arn
  iam_role_arn      = module.iam.lambda_role_arn
  eventbridge_rule_arn = module.eventbridge.rule_arn
}

module "eventbridge" {
  source = "./modules/eventbridge"
  
  rule_name       = var.rule_name
  cron_expression = var.cron_expression
  lambda_arn      = module.lambda.lambda_arn
  iam_role_arn    = module.iam.eventbridge_role_arn
}

module "sns" {
  source = "./modules/sns"
  
  topic_name  = var.sns_topic_name
  subscribers = var.sns_subscribers
}

module "iam" {
  source = "./modules/iam"
  
  role_name = var.iam_role_name
}

module "ssm" {
  source = "./modules/ssm"
  
  document_name = var.ssm_document_name
}
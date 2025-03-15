aws_region  = ""
aws_profile = "default"

lambda_function_name = "clip-noprod-octopus-cert-notify-lambda"
lambda_handler      = "lambda_function.lambda_handler"
lambda_runtime      = "python3.9"

rule_name       = "clip-noprod-octopus-cert-notify-rule"
cron_expression =  "0/2 * * * ? *"

sns_topic_name = "clip-noprod-octopus-cert-notify"
sns_subscribers = [
  
]

iam_role_name = "clip-noprod-octopus-cert-notify_IAM_role"
ssm_document_name = "clip-noprod-octopus-cert-notify-execute-script"
aws_region = "us-east-1"
role_name = "clip-noprod-octopus-cert-notify_IAM_role"
document_name = "clip-noprod-octopus-cert-notify-execute-script"
schedule_name = "clip-noprod-octopus-cert-notify-rule"
schedule_expression = "cron(0 6,18 * * ? *)"
timezone = "Europe/Paris"
sns_topic_name = "clip-noprod-octopus-cert-notify"
email_endpoints = ["bhattacharjee.soumen@gmail.com"]

# Lambda-specific variables
lambda_function_name = "clip-noprod-octopus-cert-notify-lambda"
lambda_handler = "lambda_function.lambda_handler"
lambda_runtime = "python3.9"
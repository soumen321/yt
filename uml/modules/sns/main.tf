resource "aws_sns_topic" "cert_notify" {
  name = var.topic_name
}

resource "aws_sns_topic_subscription" "email" {
  count     = length(var.email_endpoints)
  topic_arn = aws_sns_topic.cert_notify.arn
  protocol  = "email"
  endpoint  = var.email_endpoints[count.index]
}
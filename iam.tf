data "template_file" "policy" {
  template = file("${path.module}/files/es_policy.json")
  vars = {
    s3_bucket_arn = var.s3_bucket_arn
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${var.name_prefix}alb-logs-to-elasticsearch"
  path        = "/"
  description = "Policy for ${var.name_prefix}alb-logs-to-elasticsearch Lambda function"
  policy      = data.template_file.policy.rendered
}

resource "aws_iam_role" "role" {
  name = "${var.name_prefix}alb-logs-to-elasticsearch"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "policy_attachment_vpc" {
  count      = length(var.subnet_ids) > 0 ? 1 : 0
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

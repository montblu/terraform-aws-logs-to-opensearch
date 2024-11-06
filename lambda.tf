resource "aws_lambda_function" "alb_logs_to_elasticsearch_vpc" {
  filename         = local.lambda_function_filename
  function_name    = local.resource_name
  description      = local.resource_name
  timeout          = 600  # Set this to 10 minutes to avoid timeouts in case of a large VPC flow logs
  memory_size      = 1024 # Set this to 1024MB to avoid timeouts in case of a large VPC flow logs
  runtime          = "nodejs${var.nodejs_version}"
  role             = aws_iam_role.role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256(local.lambda_function_filename)

  environment {
    variables = {
      es_endpoint = var.es_endpoint
      region      = var.region
    }
  }

  tags = merge(
    var.tags,
    tomap({ "Scope" = local.resource_name }),
  )

  # This will be a code block with empty lists if we don't create a securitygroup and the subnet_ids are empty.
  # When these lists are empty it will deploy the lambda without VPC support.
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_lambda_permission" "allow_terraform_bucket_vpc" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alb_logs_to_elasticsearch_vpc.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

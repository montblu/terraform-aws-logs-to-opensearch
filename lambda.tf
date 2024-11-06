resource "aws_lambda_function" "alb_logs_to_elasticsearch" {
  count            = length(var.subnet_ids) == 0 ? 1 : 0
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
    tomap({ "Scope" = local.resource_name })
  )

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_lambda_permission" "allow_terraform_bucket" {
  count         = length(var.subnet_ids) == 0 ? 1 : 0
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alb_logs_to_elasticsearch[0].arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

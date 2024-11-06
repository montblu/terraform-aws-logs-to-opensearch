locals {
  resource_name            = "${var.name_prefix}-${var.name}"
  lambda_function_filename = var.lambda_function_filename == "" ? "${path.module}/alb-logs-to-elasticsearch.zip" : var.lambda_function_filename
}

locals {
  package_url = var.desired_version != "" ? "https://github.com/montblu/aws-logs-to-opensearch/releases/download/${var.desired_version}/aws-logs-to-opensearch-${var.desired_version}.tar.gz" : "https://github.com/montblu/aws-logs-to-opensearch/releases/download/${data.external.latest_release.result["tag"]}/aws-logs-to-opensearch-${data.external.latest_release.result["tag"]}.tar.gz"
  downloaded  = "/tmp/${md5(local.package_url)}.tar.gz"
}

data "external" "latest_release" {
  program = ["bash", "${path.module}/files/fetch_release.sh"]
}

resource "null_resource" "download_package" {
  triggers = {
    downloaded = local.downloaded
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e
      curl -L -o ${local.downloaded} ${local.package_url}
      mkdir -p /tmp/extracted_package
      tar -xzf ${local.downloaded} -C /tmp/extracted_package
      cd /tmp/extracted_package
      zip -r /tmp/alb-logs-to-elasticsearch.zip .
      cd -
      mv /tmp/alb-logs-to-elasticsearch.zip ${path.module}/
    EOT
  }
}
data "null_data_source" "downloaded_package" {
  inputs = {
    id       = null_resource.download_package.id
    filename = local.downloaded
  }
}

module "alb_logs_to_elasticsearch_vpc" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = local.resource_name
  description   = local.resource_name

  handler                = "index.handler"
  runtime                = "nodejs${var.nodejs_version}"
  memory_size            = 1024 # Set this to 1024MB to avoid timeouts in case of a large VPC flow logs
  timeout                = 600  # Set this to 10 minutes to avoid timeouts in case of a large VPC flow logs
  lambda_role            = aws_iam_role.role.arn
  local_existing_package = "${path.module}/alb-logs-to-elasticsearch.zip"
  create_role            = false
  create_package         = false
  publish                = true

  environment_variables = {
    INDEX_PREFIX                  = var.name_prefix
    VPC_SEND_ONLY_LOGS_WITH_PORTS = var.send_only_vpc_logs_with_dest_ports
    es_endpoint                   = var.es_endpoint
    region                        = var.region
  }

  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = [aws_security_group.lambda.id]

  tags = merge(
    var.tags,
    tomap({ "Scope" = local.resource_name }),
  )

  allowed_triggers = {
    S3 = {
      principal  = "s3.amazonaws.com"
      source_arn = var.s3_bucket_arn
    }
  }
}

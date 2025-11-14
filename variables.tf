variable "es_endpoint" {
  type        = string
  description = "AWS elasticsearch endpoint. Without http:// or https:// "
}

variable "lambda_function_filename" {
  type        = string
  description = "Filename with the lambda's source code"
  default     = ""
}

variable "nodejs_version" {
  type        = string
  description = "Nodejs version to be used"
  default     = "22.x"
}

variable "name" {
  type        = string
  description = "Name of the resource."
}

variable "name_prefix" {
  type        = string
  description = "A name_prefix for the resource names, this helps create multiple instances of this stack for different environments"
  default     = ""
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "s3_bucket_arn" {
  type        = string
  description = "The arn of the s3 bucket containing the alb logs"
}

variable "s3_bucket_id" {
  type        = string
  description = "The id of the s3 bucket containing the alb logs"
}

variable "subnet_ids" {
  description = "Subnet IDs you want to deploy the lambda in. Only fill this in if you want to deploy your Lambda function inside a VPC."
  type        = list(string)
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}

variable "send_only_vpc_logs_with_dest_ports" {
  description = "Send only VPC logs with the Destination Port(s). Example '22,23'"
  type        = string
  default     = ""
}

variable "desired_version" {
  type        = string
  description = "Desired version to fetch. Will get latest if left empty"
  default     = ""
}

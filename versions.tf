
terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }
    external   = {
      source  = "hashicorp/external"
      version = ">= 2.3.5"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.4"
    }
  }
}

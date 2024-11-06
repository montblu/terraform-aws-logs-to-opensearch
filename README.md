# terraform-aws-alb-logs-to-elasticsearch
Send ALB logs from S3 bucket to ElasticSearch using AWS Lambda

This directory contains terraform module to send ALB logs from S3 bucket to ElasticSearch using AWS Lambda

Particularly it creates:

1. Lambda function that does the sending
2. IAM role and policy that allows access to ES
3. S3 bucket notification that triggers the lambda function when an S3 object is created in the bucket.
4. (Only when your Lambda is deployed inside a VPC) Security group for Lambda function

## Module Input Variables


| Variable Name            | Example Value                                                        | Description                                                                                                             | Default Value                                  | Required |
| ------------------------ | -------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- | -------- |
| es_endpoint              | search-es-demo-zveqnhnhjqm5flntemgmx5iuya.eu-west-1.es.amazonaws.com | AWS ES fqdn without http://                                                                                             | `None`                                         | True     |
| region                   | `eu-west-1`                                                          | AWS region                                                                                                              | `None`                                         | True     |
| nodejs_version           | `16.x`                                                               | Nodejs version to be used                                                                                               | `14.x`                                         | False    |
| name_prefix                   | `public-`                                                            | A name_prefix for the resource names, this helps create multiple instances of this stack for different environments          |                                                | False    |
| s3_bucket_arn            | alb-logs                                                             | The arn of the s3 bucket containing the alb logs                                                                        | `None`                                         | True     |
| s3_bucket_id             | alb-logs                                                             | The id of the s3 bucket containing the alb logs                                                                         | `None`                                         | True     |
| subnet_ids               | `["subnet-1111111", "subnet-222222"]`                                | Subnet IDs you want to deploy the lambda in. Only fill this in if you want to deploy your Lambda function inside a VPC. |                                                | False    |
| lambda_function_filename | `lambda_code.zip`                                                    | Filename with the lambda's source code.                                                                                 | `${path.module}/alb-logs-to-elasticsearch.zip` | False    |

## Example

```
provider "aws" {
  region = "eu-central-1"
}

module "public_alb_logs_to_elasticsearch" {
  source        = "neillturner/alb-logs-to-elasticsearch/aws"
  version       = "0.2.2"

  name_prefix        = "public_es_"
  es_endpoint   = "test-es-XXXXXXX.eu-central-1.es.amazonaws.com"
  s3_bucket_arn = "arn:aws:s3:::XXXXXXX-alb-logs-eu-west-1"
  s3_bucket_id  = "XXXXXXX-alb-logs-eu-west-1"
  region        = "eu-west-1"
}

module "vpc_alb_logs_to_elasticsearch" {
  source        = "neillturner/alb-logs-to-elasticsearch/aws"
  version       = "0.2.2"

  name_prefix        = "vpc_es_"
  es_endpoint   = "vpc-gc-demo-vpc-gloo5rzcdhyiykwdlots2hdjla.eu-central-1.es.amazonaws.com"
  s3_bucket_arn = "arn:aws:s3:::XXXXXXX-alb-logs-eu-west-1"
  s3_bucket_id  = "XXXXXXX-alb-logs-eu-west-1"
  subnet_ids    = ["subnet-d9990999"]
  region        = "eu-west-1"
}
```

## Deployment Package Creation

The zip file alb-logs-to-elasticsearch.zip was build from [neillturner/aws-alb-logs-to-elasticsearch](https://github.com/neillturner/aws-alb-logs-to-elasticsearch)

1. On your development machine, download and install [Node.js](https://nodejs.org/en/).
2. Go to root folder of the repository and install node dependencies by running:

   ```
   npm install
   ```

   Verify that these are installed within the `node_modules` subdirectory.
3. Create a zip file to package the *index.js* and the `node_modules` directory

   ```
   zip -r9 alb-logs-to-elasticsearch.zip *
   ```

The zip file thus created is the Lambda Deployment Package.

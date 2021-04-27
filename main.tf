terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region = var.region
}

module "dynamodb" {
  source = "./modules/dynamodb"
  stage  = var.stage
  prefix = var.prefix
}

module "lambda" {
  source              = "./modules/lambda"
  dynamodb_table_name = module.dynamodb.table_name
  dynamodb_arn        = module.dynamodb.arn
  kms_arn             = module.dynamodb.kms_arn
  prefix              = var.prefix
}

resource "random_string" "password" {
  length      = 16
  min_lower   = 4
  min_numeric = 2
  special     = false
}

module "cognito_userpool" {
  source                 = "./modules/cognito_userpool"
  region                 = var.region
  prefix                 = var.prefix

  username = var.username == null ? "testuser" : var.username
  password = var.password == null ? random_string.password.result : var.password
}

module "api_gateway" {
  source                 = "./modules/api_gateway"
  stage                  = var.stage
  lambda_invoke_arn      = module.lambda.invoke_arn
  lambda_name            = module.lambda.function_name
  cognito_user_pool_name = module.cognito_userpool.user_pool_name

  depends_on = [
    module.cognito_userpool
  ]
}

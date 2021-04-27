output "api_url" {
  value = module.api_gateway.base_url
}

output "userpool_id" {
  value = module.cognito_userpool.user_pool_id
}

output "cognito_domain" {
  value = module.cognito_userpool.cognito_domain
}

output "api_key" {
  value     = module.api_gateway.api_key
  sensitive = true
}

output "client_id" {
  value = module.cognito_userpool.client_id
}

output "dynamodb_name" {
  value = module.dynamodb.table_name
}

output "dynamodb_arn" {
  value = module.dynamodb.arn
}

output "dynamodb_cmk_arn" {
  value = module.dynamodb.kms_arn
}
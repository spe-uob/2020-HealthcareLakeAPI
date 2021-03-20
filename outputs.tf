output "api_url" {
  value = module.api_gateway.base_url
}

output "userpool_id" {
  value = module.cognito_userpool.user_pool_id
}

output "api_key" {
  value = module.api_gateway.api_key
}

output "client_id" {
  value = module.cognito_userpool.client_id
}
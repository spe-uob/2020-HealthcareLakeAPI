output "user_pool_name" {
	value = aws_cognito_user_pool.pool.name
}

output "cognito_domain" {
  value = aws_cognito_user_pool_domain.api_pool_domain.domain
}

output "user_pool_id" {
	value = aws_cognito_user_pool.pool.id
}

output "client_id" {
	value = aws_cognito_user_pool_client.client.id
}

output "cognito_pool_arn" {
	value = aws_cognito_user_pool.pool.arn
}

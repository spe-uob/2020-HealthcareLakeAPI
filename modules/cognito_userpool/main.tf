resource "aws_cognito_user_pool" "pool" {
  name = "${var.prefix}-DataSimulationPool"
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = false  
    require_symbols   = false
    require_numbers   = true
    temporary_password_validity_days = 7
  }

  device_configuration {
    challenge_required_on_new_device = false
  }

  username_configuration {
    case_sensitive = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name            = "${var.prefix}-SimulationApp"
  user_pool_id    = aws_cognito_user_pool.pool.id
  generate_secret = false

  allowed_oauth_flows                   = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client  = true
  allowed_oauth_scopes                  = ["email", "openid", "profile"]

  callback_urls        = ["http://localhost"]
  default_redirect_uri = "http://localhost"

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]

  supported_identity_providers = ["COGNITO"]

  prevent_user_existence_errors = "ENABLED"
}

resource "aws_cognito_user_pool_domain" "api_pool_domain" {
  domain = aws_cognito_user_pool_client.client.id
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "null_resource" "cognito_user" {
  triggers = {
    user_pool_id = aws_cognito_user_pool.pool.id
  }

  // Terraform doesn't support the creation of accounts so this has to be run
  // Also, admin created accounts require password change at first use thus this manual fix
  provisioner "local-exec" {
    command = <<EOF
aws cognito-idp admin-create-user --region ${var.region} --user-pool-id ${aws_cognito_user_pool.pool.id} --username ${var.username} && \
aws cognito-idp admin-set-user-password --region ${var.region} --user-pool-id ${aws_cognito_user_pool.pool.id} --username ${var.username} --password ${var.password} --permanent
EOF
  }
}
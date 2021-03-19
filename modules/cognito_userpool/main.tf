resource "aws_cognito_user_pool" "pool" {
  name = "DataSimulationPool"
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = false  
    require_symbols   = false
    require_numbers   = true
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
  name            = "SimulationApp"
  user_pool_id    = aws_cognito_user_pool.pool.id
  generate_secret = false
}

resource "null_resource" "cognito_user" {
  triggers = {
    user_pool_id = aws_cognito_user_pool.pool.id
  }

  // Terraform doesn't support the creation of accounts so this has to be run
  // Also, admin created accounts require password change at first use thus this manual fix
  provisioner "local-exec" {
    command = "aws cognito-idp admin-create-user --user-pool-id ${aws_cognito_user_pool.pool.id} --username ${var.username} && aws cognito-idp admin-set-user-password --user-pool-id ${aws_cognito_user_pool.pool.id} --username ${var.username} --password ${var.password} --permanent"
  }
}
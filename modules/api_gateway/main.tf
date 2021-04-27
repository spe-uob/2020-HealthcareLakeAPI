// REST API
resource "aws_api_gateway_rest_api" "fhir" {
  name = "FHIR API"
  description = "RESTful FHIR API"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.fhir.id
  parent_id = aws_api_gateway_rest_api.fhir.root_resource_id
  // matches any request path
  path_part = "{proxy+}"
}
resource "aws_api_gateway_method" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.fhir.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.auth.id
  api_key_required = false
}

// Data source for userpool arn
data "aws_cognito_user_pools" "selected" {
  name = var.cognito_user_pool_name
}

// The API authorizer using COGNITO_USER_POOLS
resource "aws_api_gateway_authorizer" "auth" {
  name                   = "cognito_authorizer"
  type                   = "COGNITO_USER_POOLS"
  rest_api_id            = aws_api_gateway_rest_api.fhir.id
  provider_arns          = data.aws_cognito_user_pools.selected.arns
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.fhir.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = var.lambda_invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
   rest_api_id   = aws_api_gateway_rest_api.fhir.id
   resource_id   = aws_api_gateway_rest_api.fhir.root_resource_id
   http_method   = "ANY"
   authorization = "COGNITO_USER_POOLS"
   authorizer_id = aws_api_gateway_authorizer.auth.id
   api_key_required = true

   request_parameters = {
    "method.request.path.proxy" = false
  }
}

resource "aws_api_gateway_integration" "lambda_root" {
   rest_api_id = aws_api_gateway_rest_api.fhir.id
   resource_id = aws_api_gateway_method.proxy_root.resource_id
   http_method = aws_api_gateway_method.proxy_root.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "fhir" {
   depends_on = [
     aws_api_gateway_integration.lambda,
     aws_api_gateway_integration.lambda_root,
   ]

   rest_api_id = aws_api_gateway_rest_api.fhir.id
   stage_name = var.stage
}

resource "aws_api_gateway_api_key" "app_key" {
  name = "APIKey"
}
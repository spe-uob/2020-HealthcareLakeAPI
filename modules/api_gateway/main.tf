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
  authorization = "NONE"
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
   authorization = "NONE"
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
   stage_name  = var.stage
}
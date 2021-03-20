output "base_url" {
  value = aws_api_gateway_deployment.fhir.invoke_url
}

output "api_key" {
  value = aws_api_gateway_api_key.app_key.value
}
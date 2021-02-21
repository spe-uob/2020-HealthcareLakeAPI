output "base_url" {
  value = aws_api_gateway_deployment.fhir.invoke_url
}
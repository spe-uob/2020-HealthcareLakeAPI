output "table_name" {
  value = aws_dynamodb_table.fhir.name
}

output "arn" {
  value = aws_dynamodb_table.fhir.arn
}

output "kms_arn" {
  value = aws_kms_key.fhir.arn
}
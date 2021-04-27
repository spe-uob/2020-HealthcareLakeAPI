/*
  DynamoDB schema for FHIR
*/
resource "aws_dynamodb_table" "fhir" {
  name    = "${var.prefix}-fhir-${var.stage}"
  billing_mode = "PAY_PER_REQUEST"
  
  hash_key = "id"
  
  attribute {
    name  = "id"
    type = "S"
  }

  server_side_encryption {
    enabled  = true
    kms_key_arn = aws_kms_key.fhir.arn
  }
}

// KMS key
resource "aws_kms_key" "fhir" {
  description = "FHIR dynamodb KMS key"
}
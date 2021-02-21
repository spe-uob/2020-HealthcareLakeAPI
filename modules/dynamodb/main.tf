/*
  DynamoDB schema for FHIR
*/
resource "aws_dynamodb_table" "fhir" {
  name    = "fhir-${var.stage}"
  billing_mode = "PAY_PER_REQUEST"
  
  hash_key = "id"
  range_key = "vid"
  
  attribute {
    name  = "id"
    type = "S"
  }
  attribute {
    name  = "vid"
    type  = "N"
  }

  # server_side_encryption {
  #   enabled  = true
  #   kms_key_arn = var.kms
  # }
}

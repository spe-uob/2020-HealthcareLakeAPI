package main

do_not_delete = [
  "aws_dynamodb_table.fhir",
  "aws_kms_key.fhir"
]

deny[msg] {
  check_delete_protected(input.resource_changes, do_not_delete)
  msg = "Terraform plan will delete a protected resource"
}

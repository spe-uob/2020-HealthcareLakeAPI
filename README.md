[![Terraform](https://github.com/spe-uob/HealthcareLakeAPI/actions/workflows/terraform.yml/badge.svg?branch=main)](https://github.com/spe-uob/HealthcareLakeAPI/actions/workflows/terraform.yml)

# HealthcareLakeAPI

This is a pluggable component for data ingestion into the [HealthcareLake](https://github.com/spe-uob/HealthcareLake). It accepts new FHIR records as a `POST` request. Full usage instructions are maintained [here](https://joekendal.gitbook.io/healthcare-data-lake/api/usage).

## Usage

```sh
terraform apply
```
or as a module import:
```tf
module "fhir_api" {
  source = "git@github.com:spe-uob/HealthcareDataLakeAPI.git"
  
  region = var.region
  stage  = var.stage
}
```

## About

Based a bit on FHIR Works on AWS, this is a rewrite to:

1. Reduce the lambda execution costs significantly by using Golang instead of Node.js

2. Improve readability of the application code logic

3. Simplify the IaC by using Terraform instead of CloudFormation

This won't implement all the FHIR spec and is just being used as a module for a data lake ingestion component. Therefore it currently only supports `create` method using `POST`, as that's all we need.

Currently we don't need unstructured data through the `/Binary` resource and so that can be added later with an S3 module.

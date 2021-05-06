[![Terraform](https://github.com/spe-uob/HealthcareLakeAPI/actions/workflows/terraform.yml/badge.svg?branch=main)](https://github.com/spe-uob/HealthcareLakeAPI/actions/workflows/terraform.yml)
[![Scan](https://github.com/spe-uob/HealthcareLakeAPI/workflows/Scan/badge.svg)](https://github.com/accurics/terrascan)


# HealthcareLakeAPI

This is a pluggable component for data ingestion into the [HealthcareLake](https://github.com/spe-uob/HealthcareLake). It accepts new FHIR records as a `POST` request. Full usage instructions are maintained [here](https://spe-uob.gitbook.io/healthcare-data-lake/api/usage).

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

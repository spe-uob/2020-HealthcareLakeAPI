# fhir-definitely-works-on-aws

Based a bit on FHIR Works on AWS, FHIR Definitely Works on AWS seeks to:

1. Reduce the lambda execution costs significantly by using Golang instead of Node.js

2. Improve readability of the application code logic

3. Simplify the IaC by using Terraform instead of CloudFormation

This won't implement all the FHIR spec and is just being used as a module for a data lake ingestion component. Therefore it currently only supports `create` method using `POST`, as that's all we need.
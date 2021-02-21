// lambda function role
resource "aws_iam_role" "lambda" {
  name               = "LambdaExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

// assume lambda role (boilerplate code)
data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "fhir_role_policy" {
  name = "FhirLambdaRolePolicy"
  role = aws_iam_role.lambda.name
  policy = data.aws_iam_policy_document.fhir_policy.json
}

data "aws_iam_policy_document" "fhir_policy" {
  // Allow decrypting DynamoDB
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
    ]
    effect = "Allow"
    resources = [
      var.kms_arn
    ]
  }
  // Allow CRUD on DynamoDB
  statement {
    actions = [
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:BatchWriteItem"
    ]
    effect = "Allow"
    resources = [
      var.dynamodb_arn
    ]
  }
  // Allow CloudWatch
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

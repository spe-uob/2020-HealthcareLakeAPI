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
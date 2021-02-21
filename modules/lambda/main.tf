// compiles golang lambda
resource "null_resource" "build" {
  // re-builds if file hash changes
  triggers = {
    main    = base64sha256(file("${path.module}/src/main.go"))
    execute = base64sha256(file("${path.module}/build.sh"))
  }
  // build script to run
  provisioner "local-exec" {
    command = "${path.module}/build.sh ${path.module}/src"
  }
}

// zips the lambda for aws deployment
data "archive_file" "source" {
  type        = "zip"
  source_file = "${path.module}/main"
  output_path = "${path.module}/lambda.zip"
  depends_on  = [null_resource.build]
}

// Lambda function for Golang
resource "aws_lambda_function" "lambda" {
  function_name = "lambda"

  filename         = "${path.module}/lambda.zip"
  source_code_hash = data.archive_file.source.output_base64sha256

  role = aws_iam_role.lambda.arn

  handler = "main"
  runtime = "go1.x"

  timeout = 120
  publish = true

  environment {
    variables = {
      HASH = base64sha256(file("${path.module}/src/main.go"))
      TABLE_NAME = var.dynamodb_table_name
    }
  }

  lifecycle {
    /*
    You can override this using the command: 
      `terraform taint aws_lambda_function.lambda`
    */
    ignore_changes = [last_modified]
  }
}


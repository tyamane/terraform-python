# Terraform Setting
#terraform {
#  required_version = "0.12.6"
#}
# AWS Provider
provider "aws" {
  region     = "ap-northeast-1"
}

locals{
  funcname = "testfunc"
}

data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "build/function"
  output_path = "lambda/function.zip"
}

data "archive_file" "layer_zip" {
  type        = "zip"
  source_dir  = "build/layer"
  output_path = "lambda/layer.zip"
}

# Layer
resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name = "${local.funcname}_lambda_layer"
  filename   = "${data.archive_file.layer_zip.output_path}"
  source_code_hash = "${data.archive_file.layer_zip.output_base64sha256}"
}

# function
resource "aws_lambda_function" "lambda_function" {
    function_name     = "${local.funcname}"  
    filename          = data.archive_file.function_zip.output_path
    source_code_hash  = data.archive_file.function_zip.output_base64sha256
    handler           = "src/index.lambda_handler"
    runtime           = "python3.10"
    role              = aws_iam_role.lambda_exec_role.arn
    layers            = ["${aws_lambda_layer_version.lambda_layer.arn}"]
    environment {
      variables = {
        cas_server = "cas"
        jwt_secret = "secret"
        roleapi    = "role"
      }
    }
}
# Function url
resource "aws_lambda_function_url" "lambda_function" {
  function_name      = aws_lambda_function.lambda_function.function_name
  authorization_type = "NONE"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Policy for Lambda function"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}

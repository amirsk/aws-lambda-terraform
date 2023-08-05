terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

}

provider "aws" {
  region = "us-east-1"
}

locals {
  availability_zone = "us-east-1a"
}

# Call the shell script to build the Lambda deployment package
resource "null_resource" "build_lambda" {
  provisioner "local-exec" {
    command     = "sh ./build_lambda.sh"
    working_dir = path.module # Set the working directory to the current module directory
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "hello_world" {
  function_name = "HelloWorldLambda"
  runtime       = "java17"
  handler       = "HelloWorld::handleRequest"
  filename      = "hello_world_lambda.zip"
  role          = aws_iam_role.lambda_role.arn

  timeout = 30
}

resource "aws_iam_role" "lambda_role" {
  name = "HelloWorldLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Attach a policy to the Lambda execution role to allow writing logs to CloudWatch
resource "aws_iam_policy" "lambda_cloudwatch_policy" {
  name        = "LambdaCloudWatchPolicy"
  description = "Policy to allow Lambda function to write logs to CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_attachment" {
  policy_arn = aws_iam_policy.lambda_cloudwatch_policy.arn
  role       = aws_iam_role.lambda_role.name
}
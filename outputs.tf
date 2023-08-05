#############################
# Lambda
#############################
output "lambda_function_name" {
  description = "The function name of Lambda."
  value       = aws_lambda_function.hello_world.function_name
}

output "lambda_arn" {
  description = "The ARN of Lambda."
  value       = aws_lambda_function.hello_world.arn
}
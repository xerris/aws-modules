output "this_lambda_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lambda_event.invoke_arn
}

output "arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lambda_event.arn
}

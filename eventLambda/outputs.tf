output "this_dynamodb_table_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lambda_event.arn
}
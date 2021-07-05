output "base_url" {
  value       = aws_api_gateway_stage.default.invoke_url
  description = "API Gateway Endpoint"
}
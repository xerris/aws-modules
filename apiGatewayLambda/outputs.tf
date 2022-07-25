output "base_url" {
  value       = aws_api_gateway_stage.apistage.invoke_url
  description = "API Gateway Endpoint"
}

output "api_gateway_id"{
  value = aws_api_gateway_rest_api.api-gw.id
}

output "stage_arn"{
  value = aws_api_gateway_stage.apistage.arn
}
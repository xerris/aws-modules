resource "aws_api_gateway_rest_api" "api-gw" {
  name        = "${var.lambda_name}-apigw"
  description = "Terraform Serverless Application Example"
  tags        = var.tags
  endpoint_configuration {
    types = var.endpoint_configuration_types
  }
}

resource "aws_api_gateway_resource" "gw-resource" {
  count = length(var.resources_path_details) > 0 ? length(var.resources_path_details) : 0

  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part   = element(var.resources_path_details, count.index).resource_path
}

resource "aws_api_gateway_method" "gw-method" {
  count = length(var.resources_path_details) > 0 ? length(var.resources_path_details) : 0

  rest_api_id   = aws_api_gateway_rest_api.api-gw.id
  resource_id   = aws_api_gateway_resource.gw-resource.*.id[count.index]
  http_method   = element(var.resources_path_details, count.index).http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "apigw-integration" {
  count = length(var.resources_path_details) > 0 ? length(var.resources_path_details) : 0

  rest_api_id             = aws_api_gateway_rest_api.api-gw.id
  resource_id             = aws_api_gateway_resource.gw-resource.*.id[count.index]
  http_method             = aws_api_gateway_method.gw-method.*.http_method[count.index]
  integration_http_method = element(var.resources_path_details, count.index).integration_type == "AWS_PROXY" ? "POST" : element(var.resources_path_details, count.index).http_method
  type                    = element(var.resources_path_details, count.index).integration_type
  uri                     = element(var.resources_path_details, count.index).integration_uri
}

resource "aws_api_gateway_method_response" "method-response" {
  count = length(var.resources_path_details) > 0 ? length(var.resources_path_details) : 0

  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  resource_id = aws_api_gateway_resource.gw-resource.*.id[count.index]
  http_method = aws_api_gateway_method.gw-method.*.http_method[count.index]
  status_code = element(var.resources_path_details, count.index).status_code
}

resource "aws_api_gateway_integration_response" "integration-response" {
  count = length(var.resources_path_details) > 0 ? length(var.resources_path_details) : 0

  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  resource_id = aws_api_gateway_resource.gw-resource.*.id[count.index]
  http_method = aws_api_gateway_method.gw-method.*.http_method[count.index]
  status_code = aws_api_gateway_method_response.method-response.*.status_code[count.index]
}

resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  depends_on  = [aws_api_gateway_method.gw-method, aws_api_gateway_integration.apigw-integration, aws_api_gateway_method_response.method-response]
}

resource "aws_api_gateway_stage" "default" {
  rest_api_id          = aws_api_gateway_rest_api.api-gw.id
  deployment_id        = aws_api_gateway_deployment.default.id
  stage_name           = var.stage_name
  xray_tracing_enabled = var.xray_tracing_enabled
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  #source_arn = "${aws_api_gateway_rest_api.api-gw.execution_arn}/*/*/*"
  source_arn = "arn:aws:execute-api:${var.region}:${var.account}:${aws_api_gateway_rest_api.api-gw.id}/*/*/*"
}
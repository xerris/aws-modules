data "aws_caller_identity" "this" {}
data "aws_region" "current" {}

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

resource "aws_cloudwatch_log_group" "logs" {
  name = "/aws/apigateway/${var.lambda_name}"
  retention_in_days = var.logs_retention
  tags        = var.tags
}

resource "aws_iam_role" "role_for_api_gateway" {
  name = "${var.lambda_name}-api-gateway-role"
  description = "custom IAM Limited Role created with APIGateway as the trusted entity"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_policy" "api_gateway_logging" {
  name        = "${var.lambda_name}-api-gateway-logging"
  path        = "/"
  description = "IAM policy for logging from the api gateway"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "gateway_logs" {
  role       = aws_iam_role.role_for_api_gateway.id
  policy_arn = aws_iam_policy.api_gateway_logging.arn
}

resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.role_for_api_gateway.arn
}

resource "aws_api_gateway_stage" "default" {
  rest_api_id          = aws_api_gateway_rest_api.api-gw.id
  deployment_id        = aws_api_gateway_deployment.default.id
  stage_name           = var.stage_name
  xray_tracing_enabled = var.xray_tracing_enabled

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.logs.arn
    format          = var.access_log_format
  }
}

resource "aws_api_gateway_method_settings" "example" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  stage_name  = var.stage_name
  method_path = "*/*"

  settings {
    data_trace_enabled = true
    metrics_enabled    = true
    logging_level      = "INFO"
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.this.account_id}:${aws_api_gateway_rest_api.api-gw.id}/*/*/*"
}
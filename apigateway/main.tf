data "aws_caller_identity" "this" {}
data "aws_region" "current" {}

locals {
  resources_association = flatten([
    for k, v in var.resources_path_details : [
      #resource_path = k
      #definitions   = [
        for details_key, details_values in v : {
          resource_path              = k
          http_method                = details_key
          integration_type           = details_values.lambda_details.type
          integration_uri            = details_values.lambda_details.uri
          lambda_name                = details_values.lambda_details.lambda_name
        }
      #]
    ]
  ])
}

resource "aws_api_gateway_rest_api" "api-gw" {
  name        = var.apigateway_name
  description = "Terraform Api Gateway"
  tags        = var.tags
  endpoint_configuration {
    types = var.endpoint_configuration_types
  }
  
  body = file("${path.module}/openapi.json")
  
}

#resource "aws_api_gateway_resource" "gw-resource" {
#  for_each = { for rs in var.resources_path_details : rs.resource_path => rs if rs.parent_resource == "root" }
#
#  rest_api_id = aws_api_gateway_rest_api.api-gw.id
#  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
#  path_part   = each.key
#}
#
#resource "aws_api_gateway_resource" "pathparam-resource" {
#  for_each = { for rs in var.resources_path_details : rs.resource_path => rs if rs.parent_resource != "root" }
#
#  rest_api_id = aws_api_gateway_rest_api.api-gw.id
#  parent_id   = aws_api_gateway_resource.gw-resource["${each.value.parent_resource}"].id
#  path_part   = each.key
#}
#
#resource "aws_api_gateway_method" "gw-method" {
#  for_each = { for rs in local.resources_association : rs.id => rs }
#
#  rest_api_id        = aws_api_gateway_rest_api.api-gw.id
#  resource_id        = each.value.parent_resource == "root" ? aws_api_gateway_resource.gw-resource["${each.value.resource_path}"].id : aws_api_gateway_resource.pathparam-resource["${each.value.resource_path}"].id
#  http_method        = each.value.http_method
#  authorization      = var.add_custom_auth ? "CUSTOM" : "NONE"
#  authorizer_id      = var.add_custom_auth ? aws_api_gateway_authorizer.custom_auth[0].id : null
#  request_parameters = length(each.value.request_querystring_params) > 0 ? each.value.request_querystring_params : null
#}
#
#resource "aws_api_gateway_integration" "apigw-integration" {
#  for_each = { for rs in local.resources_association : rs.id => rs }
#
#  rest_api_id             = aws_api_gateway_rest_api.api-gw.id
#  resource_id             = each.value.parent_resource == "root" ? aws_api_gateway_resource.gw-resource["${each.value.resource_path}"].id : aws_api_gateway_resource.pathparam-resource["${each.value.resource_path}"].id
#  http_method             = aws_api_gateway_method.gw-method["${each.value.id}"].http_method
#  integration_http_method = each.value.integration_type == "AWS_PROXY" ? "POST" : each.value.http_method
#  type                    = each.value.integration_type
#  uri                     = each.value.integration_uri
#}
#
#resource "aws_api_gateway_method_response" "method-response" {
#  for_each = { for rs in local.resources_association : rs.id => rs }
#
#  rest_api_id = aws_api_gateway_rest_api.api-gw.id
#  resource_id = each.value.parent_resource == "root" ? aws_api_gateway_resource.gw-resource["${each.value.resource_path}"].id : aws_api_gateway_resource.pathparam-resource["${each.value.resource_path}"].id
#  http_method = aws_api_gateway_method.gw-method["${each.value.id}"].http_method
#  status_code = each.value.status_code
#}
#
#resource "aws_api_gateway_integration_response" "integration-response" {
#  for_each = { for rs in local.resources_association : rs.id => rs }
#
#  rest_api_id = aws_api_gateway_rest_api.api-gw.id
#  resource_id = each.value.parent_resource == "root" ? aws_api_gateway_resource.gw-resource["${each.value.resource_path}"].id : aws_api_gateway_resource.pathparam-resource["${each.value.resource_path}"].id
#  http_method = aws_api_gateway_method.gw-method["${each.value.id}"].http_method
#  status_code = aws_api_gateway_method_response.method-response["${each.value.id}"].status_code
#}
#
resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api-gw.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/apigateway/${var.apigateway_name}"
  retention_in_days = var.logs_retention
  tags              = var.tags
}

resource "aws_iam_role" "role_for_api_gateway" {
  name        = "${var.apigateway_name}-api-gateway-role"
  description = "custom IAM Limited Role created with APIGateway as the trusted entity"
  path        = "/"

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
  name        = "${var.apigateway_name}-api-gateway-logging"
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

  depends_on = [aws_api_gateway_stage.default]
}

#resource "aws_lambda_permission" "apigw" {
#  for_each = { for rs in local.resources_association : rs.resource_path => rs }
#
#  statement_id  = "AllowAPIGatewayInvoke-${each.value.lambda_name}-${regex("[0-9A-Za-z]+", each.value.resource_path)}-${each.value.http_method}"
#  action        = "lambda:InvokeFunction"
#  function_name = each.value.lambda_name
#  principal     = "apigateway.amazonaws.com"
#
#  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.this.account_id}:${aws_api_gateway_rest_api.api-gw.id}/*/${each.value.http_method}/${each.value.resource_path}"
#}

#resource "aws_lambda_permission" "apigw_pathparam" {
#  for_each = { for rs in local.resources_association : rs.id => rs if rs.parent_resource != "root" }
#
#  statement_id  = "AllowAPIGatewayInvoke-${each.value.lambda_name}-${regex("[0-9A-Za-z]+", each.value.resource_path)}-${each.value.http_method}"
#  action        = "lambda:InvokeFunction"
#  function_name = each.value.lambda_name
#  principal     = "apigateway.amazonaws.com"
#
#  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.this.account_id}:${aws_api_gateway_rest_api.api-gw.id}/*/${each.value.http_method}/${each.value.parent_resource}/*"
#}
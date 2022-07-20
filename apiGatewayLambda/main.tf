
resource "aws_api_gateway_rest_api" "api-gw" {
  name        = var.apigateway_name
  description = var.apigateway_description
  tags        = var.tags
  endpoint_configuration {
    types = var.endpoint_configuration_types
  }

  body = var.openapi_specification

}
resource "aws_lambda_permission" "apigw" {
  for_each      = var.lambda_names
  statement_id  = "AllowAPIGatewayInvoke-${each.value}-${regex("[0-9A-Za-z]+", each.key)}-${length(split("*", each.key))}-${element(split(":", each.key), 0)}"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.account_number}:${aws_api_gateway_rest_api.api-gw.id}/*/${element(split(":", each.key), 0)}/${element(split(":", each.key), 1)}"
}

resource "aws_api_gateway_deployment" "apideploy" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api-gw.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "apistage" {
  deployment_id = aws_api_gateway_deployment.apideploy.id
  rest_api_id   = aws_api_gateway_rest_api.api-gw.id
  stage_name    = var.env
}
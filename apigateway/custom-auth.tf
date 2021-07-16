data "archive_file" "custom_auth_archived" {
  count = var.add_custom_auth ? 1 : 0

  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "lambda-custom-auth.zip"
}

resource "aws_lambda_function" "function_custom_auth" {
  count = var.add_custom_auth ? 1 : 0

  function_name    = "apigw-custom-auth"
  filename         = data.archive_file.custom_auth_archived[0].output_path
  source_code_hash = data.archive_file.custom_auth_archived[0].output_base64sha256
  handler          = "basic-custom-auth.handler"
  runtime          = var.lambda_runtime
  role             = aws_iam_role.lambda_exec[0].arn
}

resource "aws_iam_role" "lambda_exec" {
  count = var.add_custom_auth ? 1 : 0

  name = "apigw-custom-auth-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role" "invocation_role" {
  count = var.add_custom_auth ? 1 : 0

  name = "apigw_custom_auth_invocation"
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
}

resource "aws_iam_role_policy" "invocation_policy" {
  count = var.add_custom_auth ? 1 : 0

  name = "apigw-custom-auth-invocation"
  role = aws_iam_role.invocation_role[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.function_custom_auth[0].arn}"
    }
  ]
}
EOF
}

resource "aws_api_gateway_authorizer" "custom_auth" {
  count = var.add_custom_auth ? 1 : 0

  name                   = "custom-auth"
  rest_api_id            = aws_api_gateway_rest_api.api-gw.id
  authorizer_uri         = aws_lambda_function.function_custom_auth[0].invoke_arn
  authorizer_credentials = aws_iam_role.invocation_role[0].arn
  identity_source        = "method.request.header.Authorization"
}
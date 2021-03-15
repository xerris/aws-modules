data "aws_caller_identity" "this" {}
data "aws_region" "current" {}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
resource "aws_lambda_function" "lambda_event" {
  function_name = var.function_name
  description   = var.description
  timeout       = var.timeout
  memory_size   = var.memory_size
  role          = aws_iam_role.iam_for_lambda.arn

  image_config  {
      command      = [var.entrypoint]
  }

  dynamic "vpc_config" {
    for_each = var.subnet_ids != null && var.vpc_security_group_ids != null ? [true] : []
    content {
      security_group_ids = var.vpc_security_group_ids
      subnet_ids         = var.subnet_ids
    }
  }

  image_uri            = var.image
  package_type         = "Image"
}

###############################################
# IAM Policy
###############################################

##############Policies#########################
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_role_for_lambda-${var.function_name}"

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
data "aws_iam_policy_document" "lambda_policy_document" {
  statement {
    effect = "Allow"
    actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]
    resources = ["*"]
  }
  dynamic "statement" {
    for_each = var.s3_readwrite_arn_iam_list 
    content {
        effect = "Allow"
        actions = [
      "s3:HeadBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
        ]
        resources = [
        statement.value,
        "${statement.value}/*",
        ]
    }
  }
  dynamic "statement" {
    for_each = var.s3_read_arn_iam_list 
    content {
        effect = "Allow"
        actions = [
      "s3:HeadBucket",
      "s3:GetObject",
      "s3:ListBucket"
        ]
        resources = [
        statement.value,
        "${statement.value}/*",
        ]
    }
  }
  dynamic "statement" {
    for_each = var.secretsmanager_arn_iam_list 
    content {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [statement.value]
    }
  }
  dynamic "statement" {
    for_each = var.dynamodb_readwrite_arn_iam_list 
    content {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:DescribeTable"
    ]
    resources = [statement.value]
    }
  }
    dynamic "statement" {
    for_each = var.dynamodb_read_arn_iam_list 
    content {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:DescribeTable"
    ]
    resources = [statement.value]
    }
  }
  dynamic "statement" {
    for_each = var.sqs_arn_iam_list 
    content {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes",
      "sqs:DeleteMessage",
    ]
    resources = [statement.value]
    }
  }
  dynamic "statement" {
    for_each = var.lambda_arn_iam_list 
    content {
    effect = "Allow"
    actions = [
      "lambda:*",
    ]
    resources = [statement.value]
    }
  }
}
resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.function_name}-policy"
  policy = data.aws_iam_policy_document.lambda_policy_document.json
}


##############Policy attchment#########################
resource "aws_iam_policy_attachment" "lambda_attachment" {
  name       = "${var.function_name}-attachment"
  roles       = [aws_iam_role.iam_for_lambda.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}

###############################################
# S3 Event
###############################################
resource "aws_lambda_permission" "allow_bucket" {
  count = var.enable_s3_event ? 1 : 0

  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_event.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_event_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count = var.enable_s3_event ? 1 : 0

  bucket = var.bucket_event_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_event.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
###############################################
# Event -> Lambda mapping
###############################################

resource "aws_lambda_event_source_mapping" "queue_event_mapping" {
  count = var.enable_sqs_event ? 1 : 0
  event_source_arn = var.sqs_event_arn
  enabled          = true
  function_name    = var.function_name
  batch_size       = 1
  depends_on = [ aws_lambda_function.lambda_event ]
}
###############################################
# Cloudwatch Cron Enabled
###############################################

resource "aws_cloudwatch_event_rule" "schedule_lambda" {
    count = var.enable_chron ? 1 : 0
    name = "cloudwatch-cron"
    description = "fires lambda"
    schedule_expression = var.cron_expression
}

resource "aws_cloudwatch_event_target" "cloudwatch_lambda_target" {
    count = var.enable_chron ? 1 : 0
    rule = aws_cloudwatch_event_rule.schedule_lambda[count.index].name
    target_id = "invoke_lambda"
    arn = aws_lambda_function.lambda_event.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_invoke_lambda" {
    count = var.enable_chron ? 1 : 0
    statement_id = "AllowExecutionFromCloudWatchCron"
    action = "lambda:InvokeFunction"
    function_name = var.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.schedule_lambda[count.index].arn
}

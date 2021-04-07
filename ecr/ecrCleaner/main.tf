resource "aws_cloudwatch_event_rule" "night_clean" {
  name = "${var.env}-cron-ecr-clean"
  description = "Cron ECR Clean"
  schedule_expression = var.cron
}

resource "aws_cloudwatch_event_target" "target_night_clean" {
    rule = aws_cloudwatch_event_rule.night_clean.name
    target_id = "check_foo"
    arn = module.lambda_ecr_cleaner.this_lambda_function_arn
}


module "lambda_ecr_cleaner"{
  source = "../../lambda"
  function_name = "${var.env}-${var.function_name}"
  description = "Lambda function that removes the unused ecr images"
  handler       = "package.handler"
  runtime       = "python3.8"
  package_type  = "Zip"
  lambda_role   = aws_iam_role.lambda-ecr-cleaner-role.arn
  timeout = 120
  create_package = false
  create_role = false
  local_existing_package = "${path.module}/package.zip"

  environment_variables = {
    IMAGES_TO_KEEP      = tonumber(var.images_to_keep)
    IGNORE_TAGS_REGEX   = var.ignore_tags_regex
    REGION              = var.region
    REPO_NAME = var.ecr_repos_lifecycle
    DRYRUN    =  false
  }

  tags ={
    Environment = var.env
    Terraform = "true"
  }
}

resource "aws_iam_role" "lambda-ecr-cleaner-role" {
  name               = "${var.env}-lambda-ecr-cleaner-role"
  tags               = {
    Environment = var.env
    Terraform = "true"
  }

  assume_role_policy = <<-EOF
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

resource "aws_iam_role_policy" "lambda-ecr-cleaner-role-policy" {
  name = "${var.env}-lambda-ecr-cleaner-role"
  role = aws_iam_role.lambda-ecr-cleaner-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*",
        "ecs:*",
        "lambda:*",
        "logs:*",
        "s3:*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
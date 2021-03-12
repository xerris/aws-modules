resource "aws_appsync_graphql_api" "foe_api" {
  name = var.name
  schema = var.schema
  authentication_type = "AMAZON_COGNITO_USER_POOLS"
  user_pool_config {
    aws_region     = var.region
    default_action = "DENY"
    user_pool_id   = var.cognito_id
  }
}

resource "aws_ecr_repository" "ecr_foe" {
  name = var.ecr_name
}

module "lambda_source" {
    for_each = var.resolvers

    source = "../lambdaAppsyncResolver"
    image_uri = "${aws_ecr_repository.ecr_foe.repository_url}:${var.image_uri}"

    function_name = each.key
    description = lookup(each.value, "description", null)
    type = lookup(each.value, "type", null)
    field = lookup(each.value, "field", null)
    entrypoint = lookup(each.value, "entrypoint", null)
    appsync_id = aws_appsync_graphql_api.foe_api.id
}
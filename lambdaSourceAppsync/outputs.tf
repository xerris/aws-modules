
output "appsync_id" {
  value = aws_appsync_graphql_api.foe_api.uri[graphql]
}

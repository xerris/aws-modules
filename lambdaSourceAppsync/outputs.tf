output "appsync_id" {
  description = "ID of created appsync"
  value = aws_appsync_graphql_api.foe_api.id
}

output "appsync_id" {
  description = "ID of created appsync"
  value = aws_appsync_graphql_api.foe_api.uris["graphql"]
}

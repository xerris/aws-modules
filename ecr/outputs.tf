output "arn" {
  description = "Full ARN of the repository"
  value       = module.ecr.arn
}

output "name" {
  description = "The name of the repository."
  value       = module.ecr.name
}

output "registry_id" {
  description = "The registry ID where the repository was created."
  value       = module.ecr.registry_id
}

output "repository_url" {
  description = "The URL of the repository (in the form `aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName`)"
  value       = module.ecr.repository_url

}

output "ecr_name" {
  value = var.ecr_name
}

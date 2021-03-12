variable "account_id" {}
variable "region" {
  default = "us-east-1"
}
variable "env" {}
variable "ecr_name" {}
variable "image_uri" {}

variable "resolvers" {
  description = "Map of datasources to create"
  type        = any
  default     = {}
}

variable "name" {}
variable "cognito_id" {}
variable "schema" {}
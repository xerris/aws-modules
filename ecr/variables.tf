variable "owner_tag" {
    default = "DevOps Team"
}

variable "env_tag" {
    default = "dev"
}

variable "ecr_name" {
  default = "hello-world"
}

variable "region" {
  default = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(any)
}
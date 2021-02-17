variable "domain_name" {
  default = "test.com"
}

variable "alternative_names" {
  default = ["*.test.com"]
  type    = list
}
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
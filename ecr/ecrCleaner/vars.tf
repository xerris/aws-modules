variable "env" {
  default = "poc"
}
variable "dryrun" {
  default = false
}

variable "images_to_keep" {
  default = 50
}

variable "ignore_tags_regex" {
  default = "release|archive"
}

variable "function_name" {
  default = "ecr-cleanup-lambda"
}

variable "region" {
  default = "us-east-1"
}

variable "ecr_repos_lifecycle" {
  default = ""
}

variable "cron" {
  default = "cron(0 0 * * ? *)"
}
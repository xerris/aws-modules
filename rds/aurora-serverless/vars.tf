variable "AWS_REGION" {
  default = "eu-west-1"
}

# variable "PATH_TO_PRIVATE_KEY" {
#   default = "mykey"
# }

# variable "PATH_TO_PUBLIC_KEY" {
#   default = "mykey.pub"
# }

# variable "AMIS" {
#   type = map(string)
#   default = {
#     us-east-1 = "ami-13be557e"
#     us-west-2 = "ami-06b94666"
#     eu-west-1 = "ami-844e0bf7"
#   }
# }

variable "RDS_PASSWORD" {
  default = "changeme"
}

variable "instance_availability_zone" {
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
  description = "  parameter to place cluster instances in a specific AZ. If left empty, will place randomly"
}

variable "publicly_accessible" {
  type        = bool
  description = "Set to true if you want your cluster to be publicly accessible (such as via QuickSight)"
  default     = false
}

variable "cluster_family" {
  type        = string
  default     = "aurora5.6"
  description = "The family of the DB cluster parameter group"
}


variable "cluster_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default     = []
  description = "List of DB cluster parameters to apply"
}
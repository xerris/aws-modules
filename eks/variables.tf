variable "env" {
  default = ""
}

variable "vpc_id" {
  default = ""
}

variable "private_subnets_ids" {
  default = []
  type = list
}

variable "public_subnets_ids" {
  default = []
  type = list
}

variable "eks_master_role"{
  type = string
}

variable "eks_dev_role" {
  default = ""
}

variable "eks_cluster_name" {
    default = "project_eks_cluster"
}

variable "eks_cluster_version" {
    default = "1.22.0"
}

variable "cni_enabled"{
  type = bool
}

variable "cluster_public_access"{
  type = bool
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = []
}
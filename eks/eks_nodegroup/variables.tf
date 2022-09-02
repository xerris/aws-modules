variable "env" {
    default =  "dev"
}

variable "subnets_ids" {
  default = []
  type = list
}

variable "eks_cluster_name" {
    default = "project_eks_cluster"
}

variable "eks_cluster_version" {
    default = "1.19.8"
}

variable "cluster_min_node_count" {
    default = 1
}

variable "cluster_max_node_count" {
    default = 2
}

variable "node_role_arn"{
    default = ""
}

variable "cluster_node_instance_type" {
  type        = list(string)
  default = []
}

variable "cluster_node_billing_mode" {
    default = "SPOT" #ON_DEMAND
}

variable "cluster_node_disk_size"{
    default = "200"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "nodegroup_usage"{
    default = "default"
}
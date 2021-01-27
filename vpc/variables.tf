variable "region" {
  default = "us-east-1"
}

variable "vpc_name" {
  default = "test-vpc"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  type = list
}

variable "public_subnets" {
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  type = list
}

variable "enable_natgateway" {
  default = false
}

variable "enable_vpngateway" {
  default = false
}

variable "external_nat_ip_ids" {
  default = [""]
  type = list
}
variable "count_eip_nat" {
  default = 0
}

variable "owner_tag" {
    default = "DevOps Team"
}

variable "env_tag" {
    default = "dev"
}
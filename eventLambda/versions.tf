terraform {
  required_version = ">= 0.12.6"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      aws    = ">= 3.19"
    }
  }
}
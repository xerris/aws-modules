provider "aws" {
  region = var.region

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

module "store_write" {
  source          = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=master"

  parameter_write = [
    {
      name        =  var.param_name #"/cp/prod/app/database/master_password"
      value       =  var.param_value
      type        =  var.param_type
      overwrite   =  var.param_overwrite
      description =  var.param_desc
    }
  ]

   tags = {
    Owner       = var.owner_tag
    Environment = var.env_tag
    Terraform   = true
  }
}
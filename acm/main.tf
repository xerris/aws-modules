provider "aws" {
  region = var.region

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name  = var.domain_name
  zone_id      = data.aws_route53_zone.selected.zone_id

  subject_alternative_names = var.alternative_names

  tags = {
    Owner       = var.owner_tag
    Environment = var.env_tag
    Terraform   = true
  }
}
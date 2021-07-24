#locals {
#  verified_identities = {
#    "domain_record" = {
#      name = "_amazonses"
##      type = "TXT"
 #     ttl     = "600"
#      records = [join("", aws_ses_domain_identity.ses_domain.*.verification_token)]
#    }
#  }
#}

resource "aws_ses_domain_identity" "ses_domain" {
  count  = var.verify_domain ? 1 : 0
  domain = var.domain
}

resource "aws_route53_record" "verification_record" {
  count   = var.route53_domain_verification && var.verify_domain ? 1 : 0
  zone_id = var.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [join("", aws_ses_domain_identity.ses_domain.*.verification_token)]
}

#module "route53_module" {
#  source = "github.com/xerris/aws-modules//route53/modules/records"
##  create = true
#  zone_id      = var.zone_id
#  private_zone = var.private_zone
#  records = local.verified_identities
#}

#resource "aws_ses_domain_dkim" "ses_domain_dkim" {
#  count  = var.route53_verify_dkim ? 1 : 0
#  domain = join("", aws_ses_domain_identity.ses_domain.*.domain)
#}

#resource "aws_route53_record" "amazonses_dkim_record" {
#  count = var.verify_domain && var.route53_verify_dkim ? 3 : 0

#  zone_id = var.zone_id
#  name    = "${element(aws_ses_domain_dkim.ses_domain_dkim.0.dkim_tokens, count.index)}._domainkey.${var.domain}"
#  type    = "CNAME"
#  ttl     = "600"
#  records = ["${element(aws_ses_domain_dkim.ses_domain_dkim.0.dkim_tokens, count.index)}.dkim.amazonses.com"]
#}

resource "aws_ses_email_identity" "email" {
  for_each = toset(var.email_addresses)
  email    = each.key
}
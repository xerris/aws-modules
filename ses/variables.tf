variable "verify_domain" {
  type        = bool
  description = "To use the verify domain option"
  default     = false
}

variable "domain" {
  description = "The domain to create the SES identity for"
  type        = string
  default     = ""
}

variable "zone_id" {
  type        = string
  description = "If provided, the module will create Route53 DNS records used for verification"
  default     = ""
}

variable "private_zone" {
  type        = bool
  description = "To identify if it is private zone or not"
  default     = false
}

variable "route53_domain_verification" {
  type        = bool
  description = "It will create Route53 DNS records used for domain verification. Only for Route53 registered domains"
  default     = false
}

variable "route53_verify_dkim" {
  type        = bool
  description = "It will create Route53 DNS records used for DKIM verification."
  default     = false
}

variable "email_addresses" {
  type        = list(any)
  description = "List of email identities to add"
  default     = []
}
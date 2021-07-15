variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "apigateway_name" {
  description = "A unique name for your Lambda Function"
  type        = string
  default     = ""
}

variable "resources_path_details" {
  description = "Details for your api resources path and http methods"
  type = map(object({
      resource_path    = string
      http_method      = string
      integration_type = string
      integration_uri  = string
      lambda_name      = string
      status_code      = string
      parent_resource  = number
  }))
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "endpoint_configuration_types" {
  default     = ["EDGE"]
  type        = list(string)
  description = "A list of endpoint types"
}

variable "stage_name" {
  description = "A unique name for your Api Gateway Stage name"
  type        = string
  default     = ""
}

variable "xray_tracing_enabled" {
  type        = bool
  default     = false
  description = "To enable XRay"
}

variable "logs_retention" {
  type = number
  description = "Defines the number of days to retain logs"
  default = 7
}

variable "access_log_format" {
  type = string
  description = "Access log format in Common Log Format (CLF)"
  default = "$context.requestId $context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] $context.httpMethod $context.resourcePath $context.protocol $context.status $context.responseLength"
}
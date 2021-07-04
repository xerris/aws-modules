variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "lambda_name" {
  description = "A unique name for your Lambda Function"
  type        = string
  default     = ""
}

variable "resources_path_details" {
  description = "Details for your api resources path and http methods"
  type = list(object({
    resource_path    = string
    http_method      = string
    integration_type = string
    integration_uri  = string
    status_code      = string
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
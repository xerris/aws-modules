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
  type = any
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
  type        = number
  description = "Defines the number of days to retain logs"
  default     = 7
}

variable "access_log_format" {
  type        = string
  description = "Access log format in Common Log Format (CLF)"
  default     = "$context.requestId $context.identity.sourceIp $context.identity.userAgent $context.identity.caller $context.identity.user [$context.requestTime] $context.httpMethod $context.resourcePath $context.protocol $context.status $context.responseLength $context.awsEndpointRequestId $context.error.responseType $context.error.message "
}

variable "add_custom_auth" {
  type        = bool
  description = "Defines if custom auth should be added or not"
  default     = false
}

variable "lambda_runtime" {
  type        = string
  description = "The name of the runtime, Ex. python2.7, python3.7, nodejs10.x"
  default     = "nodejs10.x"
}

variable "apigw_enable_cache" {
  type        = bool
  description = "Enables or disables apigateway cache"
  default     = false
}

variable "apigw_cache_size" {
  type        = number
  description = "The size of the cache for the stage, if enabled. "
  default     = 0.5
}
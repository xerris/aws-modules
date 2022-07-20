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
variable "apigateway_description" {
  description = "What this is for in your own words"
  type        = string
  default     = ""
}
variable "openapi_specification" {
  description = "A valid OpenAPI specification document"
  type        = string
  default     = ""
}
variable "lambda_names" {
  type        = any
  default     = ""
  description = "A map of endpoints and their lambdas, in the format \"VERB:path/*\" = \"LambdaName\""
}
variable "account_number" {
  type = string
  description = "The account number of the AWS account this API Gateway will be in"
  default = ""
}
variable "aws_region"{
  type=string
  description="The region this API Gateway will be in"
  default="ca-central-1"
}
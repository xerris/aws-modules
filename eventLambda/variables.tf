////////Base Lambda Variables
variable "entrypoint" {}
variable "command" {
    default = []
}
variable "env"{}
variable "image" {}
variable "function_name" {}
variable "description" {}
variable "environment_variables" {
  description = "A map of environment variables to assign to this labmda resource."
  type        = map(string)
  default     = {}
}

////////S3 Event Variables
variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}
variable "enable_s3_event" {
    default = false
}
variable "timeout" {
    default = 30
}
variable "memory_size" {
    default = 128
}
variable "reserved_concurrent_executions" {
    default = -1
}
variable "bucket_event_arn" {
     default = null
}
variable "bucket_event_id" {
     default = null
}
////////SQS Event Variables
variable "enable_event" {
    default = false
}
variable "event_arn" {
     default = null
}

variable "event_batch_size"{
    default = 0
}

variable "event_topic"{
    default = null
}
////////Private Networking Variables
variable "subnet_ids" {
        default = null
}
variable "vpc_security_group_ids" {
        default = null
}
///////IAM Variables
variable "kafka_group_readwrite_arn_iam_list" {
    default = []
}
variable "kafka_topic_readwrite_arn_iam_list" {
    default = []
}
variable "kafka_cluster_read_arn_iam_list" {
    default = []
}
variable "s3_readwrite_arn_iam_list" {
    default = []
}
variable "s3_read_arn_iam_list" {
    default = []
}
variable "sqs_arn_iam_list" {
    default = []
}
variable "sns_arn_iam_list" {
    default = []
}
variable "ses_enable" {
    default = false
}
variable "dynamodb_readwrite_arn_iam_list" {
    default = []
}
variable "dynamodb_read_arn_iam_list" {
    default = []
}
variable "secretsmanager_arn_iam_list" {
    default = []
}
variable "lambda_arn_iam_list" {
    default = []
}
///////Chron Variables

variable "enable_chron" {
    default = false
}
variable "cron_expression" {
    default = null
}
////////SNS Event Variables
variable "enable_sns_event" {
    default = false
}
variable "sns_topic_arn" {
     default = null
}
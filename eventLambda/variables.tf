////////Base Lambda Variables
variable "entrypoint" {}
variable "env"{}
variable "image" {}
variable "function_name" {}
variable "description" {}

////////S3 Event Variables
variable "enable_s3_event" {
    default = false
}
variable "bucket_event_arn" {
     default = null
}
variable "bucket_event_id" {
     default = null
}
////////SQS Event Variables
variable "enable_sqs_event" {
    default = false
}
variable "sqs_event_arn" {
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
variable "s3_arn_iam_list" {
    default = []
}
variable "sqs_arn_iam_list" {
    default = []
}
variable "dynamodb_arn_iam_list" {
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
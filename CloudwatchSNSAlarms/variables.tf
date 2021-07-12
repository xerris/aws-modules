variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "alarm_name" {
  type        = string
  description = "The name for the alarm."
}

variable "alarm_description" {
  type        = string
  default     = ""
  description = "Description for the alarm."
}

variable "comparison_operator" {
  type        = string
  description = "The operation to use when comparing the specified Statistic and Threshold."
  sensitive   = true
}

variable "evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold."
}

variable "metric_name" {
  type        = string
  default     = "SystemErrors"
  description = "The name for the alarm's associated metric."
}

variable "namespace" {
  type        = string
  default     = "AWS/DynamoDB"
  description = "The namespace for the alarm's associated metric."
  sensitive   = true
}

variable "period" {
  type        = number
  default     = 300
  description = "The period in seconds over which the specified statistic is applied."
}

variable "statistic" {
  type        = string
  default     = "SampleCount"
  description = "The statistic to apply to the alarm's associated metric."
}

variable "threshold" {
  type        = number
  default     = 1
  description = "The value against which the specified statistic is compared."
}

variable "alarm_actions" {
  type        = list(any)
  default     = []
  description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state."
}

variable "actions_enabled" {
  type        = bool
  default     = true
  description = "Indicates whether or not actions should be executed during any changes to the alarm's state."
}

variable "ok_actions" {
  type        = list(any)
  default     = []
  description = "The list of actions to execute when this alarm transitions into an OK state from any other state."
}
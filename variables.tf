variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "account_id" {
  type        = number
  description = "AWS Account ID"
}

variable "log_retention_in_days" {
  type        = number
  default     = 3
  description = "Log retention for lambdas (days)"
}

variable "git_token" {
  type        = string
  description = "GIT Token to authenticate API calls"
}
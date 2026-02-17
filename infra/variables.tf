variable "aws_region" {
  type        = string
  description = "AWS region to deploy into."
  default     = "us-east-1"
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for naming resources."
  default     = "data-landing"
}

variable "raw_bucket_name" {
  type        = string
  description = "Optional explicit name for the raw landing bucket."
  default     = ""
}

variable "curated_bucket_name" {
  type        = string
  description = "Optional explicit name for the curated bucket."
  default     = ""
}

variable "config_bucket_name" {
  type        = string
  description = "Optional explicit name for the AWS Config delivery bucket."
  default     = ""
}

variable "raw_transition_days" {
  type        = number
  description = "Days before transitioning raw objects to STANDARD_IA."
  default     = 30
}

variable "raw_expire_days" {
  type        = number
  description = "Days before expiring raw objects."
  default     = 90
}

variable "curated_versioning_enabled" {
  type        = bool
  description = "Whether versioning is enabled for the curated bucket."
  default     = true
}

variable "budget_amount" {
  type        = number
  description = "Monthly cost budget amount in USD."
  default     = 500
}

variable "budget_alert_emails" {
  type        = list(string)
  description = "List of email addresses for budget alerts."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Mandatory resource tags."
  default = {
    App        = "data-landing"
    Env        = "dev"
    Owner      = "data-platform"
    CostCenter = "0000"
  }
}

variable "cicd_principal_arns" {
  type        = list(string)
  description = "Allowed principals that can assume the CI/CD role."
  default     = []
}

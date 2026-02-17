variable "name_prefix" {
  type        = string
  description = "Prefix used for naming resources."
}

variable "raw_bucket_arn" {
  type        = string
  description = "Raw bucket ARN."
}

variable "curated_bucket_arn" {
  type        = string
  description = "Curated bucket ARN."
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN."
}

variable "cicd_principal_arns" {
  type        = list(string)
  description = "Allowed principals that can assume the CI/CD role."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
}

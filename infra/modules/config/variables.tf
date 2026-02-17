variable "name_prefix" {
  type        = string
  description = "Prefix used for naming resources."
}

variable "config_bucket_name" {
  type        = string
  description = "S3 bucket name for AWS Config delivery."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for naming resources."
}

variable "raw_bucket_name" {
  type        = string
  description = "Raw landing bucket name."
}

variable "curated_bucket_name" {
  type        = string
  description = "Curated bucket name."
}

variable "raw_transition_days" {
  type        = number
  description = "Days before transitioning raw objects to STANDARD_IA."
}

variable "raw_expire_days" {
  type        = number
  description = "Days before expiring raw objects."
}

variable "curated_versioning_enabled" {
  type        = bool
  description = "Whether versioning is enabled for the curated bucket."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for naming resources."
}

variable "budget_amount" {
  type        = number
  description = "Monthly budget amount in USD."
}

variable "alert_emails" {
  type        = list(string)
  description = "Email list for budget alerts."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
}

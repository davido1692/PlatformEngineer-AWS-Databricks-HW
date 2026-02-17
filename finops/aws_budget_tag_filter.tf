variable "budget_amount" {
  type    = number
  default = 500
}

variable "alert_emails" {
  type    = list(string)
  default = ["finops@example.com"]
}

variable "tag_key" {
  type    = string
  default = "CostCenter"
}

variable "tag_value" {
  type    = string
  default = "1234"
}

resource "aws_budgets_budget" "tag_filtered" {
  name         = "finops-${var.tag_key}-${var.tag_value}"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = tostring(var.budget_amount)
  limit_unit   = "USD"

  cost_filters = {
    "TagKeyValue" = ["${var.tag_key}$${var.tag_value}"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
  }
}

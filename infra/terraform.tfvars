# Minimal template - fill in org-specific values
aws_region  = "us-east-1"
name_prefix = "data-landing"

# Optional explicit bucket names (leave empty to auto-generate)
raw_bucket_name     = ""
curated_bucket_name = ""
config_bucket_name  = ""

# Raw data retention
raw_transition_days = 30
raw_expire_days     = 90

# Curated data settings
curated_versioning_enabled = true

# Budgeting
budget_amount = 500
budget_alert_emails = [
  "finops@example.com"
]

# CI/CD role assumption (list of principal ARNs)
cicd_principal_arns = [
  "arn:aws:iam::123456789012:role/ci-cd-role"
]

# Mandatory tags
tags = {
  App        = "data-landing"
  Env        = "dev"
  Owner      = "data-platform"
  CostCenter = "0000"
}

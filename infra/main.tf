data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  raw_bucket_name     = var.raw_bucket_name != "" ? var.raw_bucket_name : "${var.name_prefix}-raw-${data.aws_caller_identity.current.account_id}"
  curated_bucket_name = var.curated_bucket_name != "" ? var.curated_bucket_name : "${var.name_prefix}-curated-${data.aws_caller_identity.current.account_id}"
  config_bucket_name  = var.config_bucket_name != "" ? var.config_bucket_name : "${var.name_prefix}-config-${data.aws_caller_identity.current.account_id}"
  cicd_principal_arns = length(var.cicd_principal_arns) > 0 ? var.cicd_principal_arns : ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
}

module "s3" {
  source = "./modules/s3"

  name_prefix                = var.name_prefix
  raw_bucket_name            = local.raw_bucket_name
  curated_bucket_name        = local.curated_bucket_name
  raw_transition_days        = var.raw_transition_days
  raw_expire_days            = var.raw_expire_days
  curated_versioning_enabled = var.curated_versioning_enabled
  tags                       = var.tags
}

module "iam" {
  source = "./modules/iam"

  name_prefix         = var.name_prefix
  raw_bucket_arn      = module.s3.raw_bucket_arn
  curated_bucket_arn  = module.s3.curated_bucket_arn
  kms_key_arn         = module.s3.kms_key_arn
  cicd_principal_arns = local.cicd_principal_arns
  tags                = var.tags
}

resource "aws_kms_grant" "databricks_s3" {
  name              = "${var.name_prefix}-databricks-s3-grant"
  key_id            = module.s3.kms_key_id
  grantee_principal = module.iam.databricks_role_arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "DescribeKey"]
}

module "budget" {
  source = "./modules/budget"

  name_prefix   = var.name_prefix
  budget_amount = var.budget_amount
  alert_emails  = var.budget_alert_emails
  tags          = var.tags
}

module "config" {
  source = "./modules/config"

  name_prefix        = var.name_prefix
  config_bucket_name = local.config_bucket_name
  tags               = var.tags
}

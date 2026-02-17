output "raw_bucket_name" {
  value       = module.s3.raw_bucket_name
  description = "Raw landing bucket name."
}

output "curated_bucket_name" {
  value       = module.s3.curated_bucket_name
  description = "Curated bucket name."
}

output "kms_key_arn" {
  value       = module.s3.kms_key_arn
  description = "KMS key ARN used for S3 encryption."
}

output "databricks_instance_profile" {
  value       = module.iam.databricks_instance_profile_name
  description = "Instance profile for Databricks jobs."
}

output "cicd_role_arn" {
  value       = module.iam.cicd_role_arn
  description = "CI/CD role ARN for plan/apply."
}

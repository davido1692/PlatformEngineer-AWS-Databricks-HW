output "databricks_role_arn" {
  value       = aws_iam_role.databricks.arn
  description = "Databricks role ARN."
}

output "databricks_instance_profile_name" {
  value       = aws_iam_instance_profile.databricks.name
  description = "Databricks instance profile name."
}

output "cicd_role_arn" {
  value       = aws_iam_role.cicd.arn
  description = "CI/CD role ARN."
}

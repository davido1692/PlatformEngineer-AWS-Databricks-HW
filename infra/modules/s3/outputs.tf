output "raw_bucket_name" {
  value       = aws_s3_bucket.raw.bucket
  description = "Raw bucket name."
}

output "curated_bucket_name" {
  value       = aws_s3_bucket.curated.bucket
  description = "Curated bucket name."
}

output "raw_bucket_arn" {
  value       = aws_s3_bucket.raw.arn
  description = "Raw bucket ARN."
}

output "curated_bucket_arn" {
  value       = aws_s3_bucket.curated.arn
  description = "Curated bucket ARN."
}

output "kms_key_arn" {
  value       = aws_kms_key.s3.arn
  description = "KMS key ARN."
}

output "kms_key_id" {
  value       = aws_kms_key.s3.key_id
  description = "KMS key ID."
}

output "config_bucket_name" {
  value       = aws_s3_bucket.config.bucket
  description = "AWS Config bucket name."
}

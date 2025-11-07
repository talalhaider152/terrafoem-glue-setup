
output "bucket_name" {
  description = "The name of the created S3 bucket."
  value       = aws_s3_bucket.this.bucket
}

output "script_key" {
  description = "The key of the script in the S3 bucket."
  value       = aws_s3_bucket_object.script.key
}

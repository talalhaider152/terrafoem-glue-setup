
output "glue_job_arn" {
  description = "The ARN of the Glue job."
  value       = module.glue_job.job_arn
}

output "glue_job_name" {
  description = "The name of the Glue job."
  value       = module.glue_job.job_name
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket."
  value       = module.s3_bucket.bucket_name
}

output "iam_role_arn" {
  description = "The ARN of the IAM role."
  value       = module.iam_role.iam_role_arn
}

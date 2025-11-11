
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

output "github_oidc_role_arn" {
  description = "ARN of the IAM role that GitHub Actions assumes."
  value       = module.github_oidc_role.iam_role_arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider."
  value       = module.github_oidc_role.openid_connect_provider_arn
}

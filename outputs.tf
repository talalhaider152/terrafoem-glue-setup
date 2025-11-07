
output "dev_glue_job_arn" {
  description = "The ARN of the Glue job in the dev environment."
  value       = module.dev.glue_job.job_arn
}

output "prod_glue_job_arn" {
  description = "The ARN of the Glue job in the prod environment."
  value       = module.prod.glue_job.job_arn
}

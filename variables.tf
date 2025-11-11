
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "role_name" {
  description = "IAM role name for the Glue job to assume."
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name to store Glue scripts."
  type        = string
}

variable "script_key" {
  description = "Key in S3 bucket where the Glue script will be uploaded."
  type        = string
}

variable "script_source" {
  description = "Local path to the Glue script file to upload."
  type        = string
}

variable "job_name" {
  description = "Name of the Glue job."
  type        = string
}

variable "max_capacity" {
  description = "Number of DPUs for the Glue job."
  type        = number
}

variable "timeout" {
  description = "Timeout for the Glue job in minutes."
  type        = number
}

variable "github_oidc_role_name" {
  description = "IAM role name that GitHub Actions will assume via OIDC."
  type        = string
}

variable "github_oidc_repositories" {
  description = "List of GitHub repositories (owner/name) that may assume the OIDC role."
  type        = list(string)
}

variable "github_oidc_policy_arns" {
  description = "Managed policy ARNs to attach to the GitHub OIDC role."
  type        = list(string)
  default     = []
}

variable "github_oidc_audience" {
  description = "Audience expected in the GitHub OIDC token."
  type        = string
  default     = "sts.amazonaws.com"
}

variable "github_oidc_thumbprints" {
  description = "Thumbprint list for the GitHub OIDC provider."
  type        = list(string)
  default = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58aeb9b3f0f13eb74365e2798f4a966f9b8f3c",
  ]
}

variable "github_oidc_existing_provider_arn" {
  description = "ARN of an existing GitHub OIDC provider to reuse. Leave empty to create a new provider."
  type        = string
  default     = ""
}

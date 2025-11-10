variable "aws_region" {
  description = "AWS region for the bootstrap resources."
  type        = string
  default     = "sa-east-1"
}

variable "state_bucket_name" {
  description = "Globally-unique S3 bucket name for Terraform state."
  type        = string
  default     = "remote-backend-spectre"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  type        = string
  default     = "terraform-locks"
}

variable "github_owner" {
  description = "GitHub organization or user that owns the repository."
  type        = string
  default     = "talalhaider152"
}

variable "github_repo" {
  description = "Repository name (without owner)."
  type        = string
  default     = "terrafoem-glue-setup"
}

variable "actions_role_name" {
  description = "Name of IAM role to be assumed by GitHub Actions."
  type        = string
  default     = "github-actions-terraform"
}

variable "additional_policy_arns" {
  description = "Optional extra IAM policies to attach to the GitHub Actions role for Terraform permissions."
  type        = list(string)
  default     = []
}

variable "github_oidc_provider_arn" {
  description = "ARN of existing GitHub OIDC provider (if already exists). Leave empty to create new one."
  type        = string
  default     = ""
}



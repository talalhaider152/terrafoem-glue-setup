output "iam_role_arn" {
  description = "ARN of the GitHub OIDC IAM role."
  value       = aws_iam_role.github.arn
}

output "openid_connect_provider_arn" {
  description = "ARN of the GitHub OIDC provider."
  value       = local.github_oidc_provider_arn
}


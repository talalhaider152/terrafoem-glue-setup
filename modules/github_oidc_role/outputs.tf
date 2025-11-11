output "iam_role_arn" {
  description = "ARN of the GitHub OIDC IAM role."
  value       = aws_iam_role.github.arn
}

output "openid_connect_provider_arn" {
  description = "ARN of the GitHub OIDC provider."
  value       = aws_iam_openid_connect_provider.github.arn
}


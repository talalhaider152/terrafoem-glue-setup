variable "role_name" {
  description = "Name of the IAM role that GitHub Actions will assume via OIDC."
  type        = string
}

variable "repositories" {
  description = "List of GitHub repositories (owner/name) allowed to assume the role."
  type        = list(string)

  validation {
    condition     = length(var.repositories) > 0
    error_message = "At least one repository (owner/name) must be provided for the GitHub OIDC role."
  }
}

variable "audience" {
  description = "Audience expected in the GitHub OIDC token."
  type        = string
  default     = "sts.amazonaws.com"
}

variable "thumbprints" {
  description = "Thumbprints for the GitHub OIDC provider."
  type        = list(string)
  default = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58aeb9b3f0f13eb74365e2798f4a966f9b8f3c",
  ]
}

variable "policy_arns" {
  description = "Managed policy ARNs to attach to the GitHub OIDC role."
  type        = list(string)
  default     = []
}


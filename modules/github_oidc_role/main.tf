locals {
  subjects = [
    for repository in var.repositories : "repo:${repository}:*"
  ]
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [var.audience]
  thumbprint_list = var.thumbprints
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    sid     = "AllowGitHubActionsAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = [var.audience]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.subjects
    }
  }
}

resource "aws_iam_role" "github" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.policy_arns)

  role       = aws_iam_role.github.name
  policy_arn = each.value
}


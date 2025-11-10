terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "tf_state" {
  bucket = var.state_bucket_name
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "tf_lock" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# GitHub OIDC provider
# Note: If provider already exists, import it first with:
# terraform import aws_iam_openid_connect_provider.github <ARN>
# To find ARN: aws iam list-open-id-connect-providers --query 'OpenIDConnectProviderList[?contains(Arn, `token.actions.githubusercontent.com`)].Arn' --output text
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # Current GitHub Actions root CA thumbprint
  # https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Limit to this repository
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}/${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = var.actions_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Minimal permissions for Terraform backend (S3 + DynamoDB)
data "aws_iam_policy_document" "backend" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [aws_s3_bucket.tf_state.arn]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.tf_state.arn}/*"]
  }

  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:CreateTable",
      "dynamodb:ListTables",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem"
    ]
    resources = [aws_dynamodb_table.tf_lock.arn]
  }
}

resource "aws_iam_policy" "backend" {
  name   = "${var.actions_role_name}-backend"
  policy = data.aws_iam_policy_document.backend.json
}

resource "aws_iam_role_policy_attachment" "backend" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.backend.arn
}

# Permissions for managing Glue infrastructure (IAM roles, S3 buckets, Glue jobs)
data "aws_iam_policy_document" "glue_infrastructure" {
  # IAM permissions for Glue roles
  statement {
    sid    = "IAMRoleManagement"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:CreateRole",
      "iam:UpdateRole",
      "iam:DeleteRole",
      "iam:ListRoles",
      "iam:GetRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/glue-*",
      "arn:aws:iam::*:role/*-glue-*"
    ]
  }

  # S3 permissions for Glue script buckets
  statement {
    sid    = "S3BucketManagement"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
      "s3:GetBucketAcl",
      "s3:PutBucketAcl",
      "s3:GetBucketPublicAccessBlock",
      "s3:PutBucketPublicAccessBlock"
    ]
    resources = [
      "arn:aws:s3:::*-glue-*",
      "arn:aws:s3:::dev-*",
      "arn:aws:s3:::prod-*"
    ]
  }

  statement {
    sid    = "S3ObjectManagement"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:HeadObject",
      "s3:ListObjects",
      "s3:ListObjectsV2"
    ]
    resources = [
      "arn:aws:s3:::*-glue-*/*",
      "arn:aws:s3:::dev-*/*",
      "arn:aws:s3:::prod-*/*"
    ]
  }

  # Glue permissions
  statement {
    sid    = "GlueJobManagement"
    effect = "Allow"
    actions = [
      "glue:CreateJob",
      "glue:UpdateJob",
      "glue:DeleteJob",
      "glue:GetJob",
      "glue:ListJobs",
      "glue:GetJobRun",
      "glue:ListJobRuns",
      "glue:StartJobRun",
      "glue:StopJobRun",
      "glue:BatchStopJobRun",
      "glue:GetJobRuns",
      "glue:GetConnection",
      "glue:GetConnections",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "glue_infrastructure" {
  name   = "${var.actions_role_name}-glue-infrastructure"
  policy = data.aws_iam_policy_document.glue_infrastructure.json
}

resource "aws_iam_role_policy_attachment" "glue_infrastructure" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.glue_infrastructure.arn
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each   = toset(var.additional_policy_arns)
  role       = aws_iam_role.github_actions.name
  policy_arn = each.value
}



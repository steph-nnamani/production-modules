terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Reference existing GitHub OIDC provider
data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

# Create IAM role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name_prefix        = var.role_name_prefix
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = var.tags
}

# Trust policy for GitHub Actions
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [data.aws_iam_openid_connect_provider.github_actions.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        for repo in var.allowed_repositories :
        "repo:${repo.org}/${repo.repo}:ref:refs/heads/${repo.branch}"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# Terraform backend permissions (if enabled)
resource "aws_iam_role_policy" "terraform_backend" {
  count  = var.enable_terraform_backend_access ? 1 : 0
  name   = "terraform-backend-access"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.terraform_backend[0].json
}

data "aws_iam_policy_document" "terraform_backend" {
  count = var.enable_terraform_backend_access ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.terraform_state_bucket}",
      "arn:aws:s3:::${var.terraform_state_bucket}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [
      "arn:aws:dynamodb:*:*:table/${var.terraform_lock_table}"
    ]
  }
}

# Custom permissions policy
resource "aws_iam_role_policy" "custom_permissions" {
  count  = var.custom_policy_json != "" ? 1 : 0
  name   = "custom-permissions"
  role   = aws_iam_role.github_actions.id
  policy = var.custom_policy_json
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each   = toset(var.managed_policy_arns)
  role       = aws_iam_role.github_actions.name
  policy_arn = each.value
}

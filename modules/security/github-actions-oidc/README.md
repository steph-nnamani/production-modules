# SECRET MANAGEMENT IN TERRAFORM

# Authentication methods

# 1.
# OIDC - GitHub Actions as a CI Server
--------------------------------------
To use GitHub action workflow (terraform.yml) to authenticate with aws account, we can use OIDC.
# STEPS:
1. Create an IAM OIDC identity provider in your aws account, using the aws_iam_openid_connect_provider resource, and configure it to trust the GitHub Actions thumbprint, fetched via the tls_certificate data source:


# Part 1: Fetch GitHub’s TLS Certificate

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

This Terraform data block fetches the TLS certificate chain from GitHub’s OIDC token endpoint (https://token.actions.githubusercontent.com).

- It pulls the cert so Terraform can extract its SHA-1 fingerprint.
- This is used to verify GitHub's identity.

# Part 2: Create IAM OIDC Provider

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    data.tls_certificate.github.certificates[0].sha1_fingerprint
  ]
}

- This block registers GitHub's OIDC issuer as a trusted identity provider in your AWS account.
- Explanations:                                                                
`url` :             The GitHub OIDC token URL. AWS uses this to verify tokens.                                              
`client_id_list` :  AWS service(s) that GitHub can assume roles into. `"sts.amazonaws.com"` is required for assuming roles. 
`thumbprint_list` : A hash of GitHub’s TLS cert. AWS uses this to validate that the token is truly from GitHub.     

# Why is the above code Important?
- Successfully created the OIDC provider in AWS
- Provider now exists in your AWS account
-OIDC providers are global/account-level - you only need one per AWS account
- Multiple projects can share the same GitHub OIDC provider
- Data source approach lets you reference the existing provider without trying to recreate it


<!-- You allow GitHub Actions to assume IAM roles in AWS via aws-actions/configure-aws-credentials action.

You can define fine-grained IAM role trust policies that only allow access from:

specific GitHub repositories,

specific branches or workflows.

This removes the need to store AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in GitHub secrets. -->

# How do we use this module?

module "github_actions_oidc" {
  source = "./modules/security/github-actions-oidc"

  role_name_prefix = "my-project-github-actions"
  
  allowed_repositories = [
    {
      org    = "my-org"
      repo   = "my-repo"
      branch = "main"
    }
  ]

  enable_terraform_backend_access = true
  terraform_state_bucket         = "my-terraform-state-bucket"
  terraform_lock_table          = "my-terraform-lock-table"
  # Pass the policy ARN of all the policy you want attached to your role.
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AutoScalingFullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ]

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
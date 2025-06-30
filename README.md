# RUN BOOK
==========
git repositories used for terraform-up-and-running:

https://github.com/steph-nnamani/modules.git

https://github.com/steph-nnamani/terraform-multi-repo-example.git

https://github.com/steph-nnamani/terraform-multi-repo-example.git

https://github.com/steph-nnamani/terraform-live.git

https://github.com/steph-nnamani/production-modules.git
========================================================
# Implementation:
Source module repository:
https://github.com/steph-nnamani/modules.git

Root module and .GitHub/workflows repository:
https://github.com/steph-nnamani/terraform-live.git
=========================================================



## Best Practices for Tagging Multi-Module Repositories:
1. Semantic Versioning with Module Paths
Tag Format: <module-path>/v<version>

# Tag format: <module-name>-v<version>
git tag github-actions-oidc-v1.0.0
git tag alb-v2.1.0
git tag asg-v1.5.2
git tag hello-world-app-v3.0.0

# Reference:

module "github_actions_oidc" {
  source = "git::https://github.com/your-org/terraform-modules.git//modules/security/github-actions-oidc?ref=github-actions-oidc-v1.0.0"
}


## Git Commands for Committing and Tagging Modules:
===================================================
1. Standard Commit and Push:
# Add changes
git add .

# Commit with descriptive message
git commit -m "feat: add GitHub Actions OIDC module v1.0.0

- Initial release of GitHub Actions OIDC authentication module
- Support for multiple repositories and branches
- Configurable IAM permissions"

# Push to remote
git push origin main

2. Create and push tags:
# Create annotated tag for the module
git tag -a modules/security/github-actions-oidc/v1.0.0 -m "GitHub Actions OIDC module v1.0.0

Initial release:
- OIDC provider setup
- IAM role with configurable permissions
- Support for multiple repos/branches"

# Push the tag to remote
git push origin modules/security/github-actions-oidc/v1.0.0

# Or push all tags at once
git push origin --tags

3. Complete Workflow:
# 1. Make your changes
git add modules/security/github-actions-oidc/

# 2. Commit
git commit -m "feat: add GitHub Actions OIDC module"

# 3. Push commit
git push origin main

# 4. Create tag
git tag -a modules/security/github-actions-oidc/v1.0.0 -m "Initial release"

# 5. Push tag
git push origin modules/security/github-actions-oidc/v1.0.0


4. For Multiple Modules:
# Tag multiple modules in one session
git tag -a modules/networking/alb/v2.1.0 -m "ALB module v2.1.0"
git tag -a modules/compute/asg/v1.5.0 -m "ASG module v1.5.0"

# Push all tags
git push origin --tags

5. List and Verify Tags:
# List all tags
git tag -l

# List tags for specific module
git tag -l "modules/security/github-actions-oidc/*"

# Show tag details
git show modules/security/github-actions-oidc/v1.0.0

# Key Points:
	Use annotated tags (-a) for better metadata
	Include release notes in tag messages
	Push tags separately from commits
	Use semantic versioning for module versions


===========================================================
git add .

git commit -m "Add initial modules: cluster, networking, security, services"

git push origin main

git tag -a modules/cluster/asg-rolling-deploy/v1.0.0 -m "Initial Release v1.0.0"
git tag -a modules/networking/alb/v1.0.0 -m "Initial Release v1.0.0"
git tag -a modules/security/github-actions-oidc/v1.0.0 -m "Initial Release v1.0.0"
git tag -a modules/services/hello-world-app/v1.0.0 -m "Initial Release v1.0.0"

git push origin --tags
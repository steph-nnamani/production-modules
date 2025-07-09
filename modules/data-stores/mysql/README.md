# How it works:
- Toggle variable: use_secrets_manager controls which approach to use

- Conditional data source: Secrets Manager data source only runs when needed (count = var.use_secrets_manager ? 1 : 0)

- Smart locals: The db_creds local chooses the right credential source based on the toggle

- Validation: When using variables, you must provide both db_username and db_password


Usage Examples:
# Option 1: Use Secrets Manager (default)

module "mysql" {
  source = "./modules/data-stores/mysql"
  # use_secrets_manager = true (default)
  # secrets_manager_secret_id = "db-creds" (default)
}

# or:

# Option 2: Use variables

module "mysql" {
  source = "./modules/data-stores/mysql"
  use_secrets_manager = false
  db_username = "admin"
  db_password = "your-password"
}

# The module also needs:

        VPC subnet group for network isolation

        Security group configuration

        Encryption at rest

        Enhanced monitoring options

        Proper backup configuration

        Parameter group for MySQL tuning
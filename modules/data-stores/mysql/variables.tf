variable "use_secrets_manager" {
  type = bool
  description = "Whether to use AWS Secrets Manager for credentials (true) or variables (false)"
  default = true
}

variable "secrets_manager_secret_id" {
  type = string
  description = "AWS Secrets Manager secret ID for database credentials"
  default = "db-creds"
}

variable "db_username" {
  type = string
  sensitive = true
  description = "Username for the database (used when use_secrets_manager = false)"
  default = null
}

variable "db_password" {
  type = string
  sensitive = true
  description = "Password for the database (used when use_secrets_manager = false)"
  default = null
}

variable "region" {
  type = string
  description = "AWS region"
  default = "us-east-1"
}

variable "rds" {
  type = string
  description = "prefix name to distinguish of the RDS instance env"
  default = "awsprodrds"  # does not accept '-' hyphen
 }

variable "instance_class" {
  type = string
  description = "Instance class for the RDS instance"
  default = "db.t3.micro"
}

# Network Security
variable "vpc_id" {
  type = string
  description = "VPC ID where the database will be created"
}

variable "subnet_ids" {
  type = list(string)
  description = "List of subnet IDs for the DB subnet group"
}

variable "allowed_cidr_blocks" {
  type = list(string)
  description = "List of CIDR blocks allowed to access the database"
  default = []
}

# Storage
variable "allocated_storage" {
  type = number
  description = "Initial allocated storage in GB"
  default = 20
}

variable "max_allocated_storage" {
  type = number
  description = "Maximum allocated storage for autoscaling"
  default = 100
}

variable "storage_encrypted" {
  type = bool
  description = "Enable storage encryption"
  default = true
}

variable "kms_key_id" {
  type = string
  description = "KMS key ID for encryption"
  default = null
}

# Backup & Maintenance
variable "backup_retention_period" {
  type = number
  description = "Backup retention period in days"
  default = 7
}

variable "backup_window" {
  type = string
  description = "Preferred backup window"
  default = "03:00-04:00"
}

variable "maintenance_window" {
  type = string
  description = "Preferred maintenance window"
  default = "sun:04:00-sun:05:00"
}

# Monitoring
variable "monitoring_interval" {
  type = number
  description = "Enhanced monitoring interval in seconds (0 to disable)"
  default = 0
}

variable "performance_insights_enabled" {
  type = bool
  description = "Enable Performance Insights"
  default = false
}

# Replica Configuration
variable "replicate_source_db" {
  type = string
  description = "Identifier of the source database for read replica (leave empty for primary)"
  default = null
}

# Tags
variable "tags" {
  type = map(string)
  description = "Tags to apply to resources"
  default = {}
}

variable "engine" {
  type = string
  description = "Database engine for the RDS instance"
  default = "mysql"
}

variable "engine_version" {
  type = string
  description = "Database engine version for the RDS instance"
  default = "8.0.28"
}


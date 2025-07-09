terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Security Group for RDS (only for primary)
resource "aws_security_group" "rds" {
  count       = var.replicate_source_db == null ? 1 : 0
  name_prefix = "${var.rds}_database"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.rds}-rds-sg"
  })
}

# DB Subnet Group (only for primary)
resource "aws_db_subnet_group" "main" {
  count      = var.replicate_source_db == null ? 1 : 0
  name       = "${var.rds}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.rds}-subnet-group"
  })
}

# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  name  = "${var.rds}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "example" {
  identifier_prefix   = "${var.rds}-instance"
  instance_class     = var.instance_class
  skip_final_snapshot = true

  # Replica Configuration
  replicate_source_db = var.replicate_source_db

  # Primary DB Configuration (only when not a replica)
  engine             = var.replicate_source_db == null ? "mysql" : null
  engine_version     = var.replicate_source_db == null ? "8.0" : null
  allocated_storage  = var.replicate_source_db == null ? var.allocated_storage : null
  max_allocated_storage = var.replicate_source_db == null ? var.max_allocated_storage : null
  db_name           = var.replicate_source_db == null ? "${var.rds}_database" : null
  storage_encrypted = var.storage_encrypted
  kms_key_id = var.kms_key_id

  # Network & Security (only for primary)
  db_subnet_group_name   = var.replicate_source_db == null ? aws_db_subnet_group.main[0].name : null
  vpc_security_group_ids = var.replicate_source_db == null ? [aws_security_group.rds[0].id] : null

  # Backup & Maintenance (only for primary)
  backup_retention_period = var.replicate_source_db == null ? var.backup_retention_period : null
  backup_window          = var.replicate_source_db == null ? var.backup_window : null
  maintenance_window     = var.replicate_source_db == null ? var.maintenance_window : null

  # Monitoring
  monitoring_interval                = var.monitoring_interval
  monitoring_role_arn               = var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  performance_insights_enabled      = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? 7 : null

  # Credentials (only for primary)
  username = var.replicate_source_db == null ? local.db_creds.username : null
  password = var.replicate_source_db == null ? local.db_creds.password : null

  tags = var.tags
}

data "aws_secretsmanager_secret_version" "creds" {
  count     = var.use_secrets_manager ? 1 : 0
  secret_id = var.secrets_manager_secret_id
}

# Accepts either secrets manager or use of variables for credentials
locals {
  db_creds = var.use_secrets_manager ? {
    username = jsondecode(data.aws_secretsmanager_secret_version.creds[0].secret_string).username
    password = jsondecode(data.aws_secretsmanager_secret_version.creds[0].secret_string).password
  } : {
    username = var.db_username
    password = var.db_password
  }
}


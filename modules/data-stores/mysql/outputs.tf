output "address" {
  value = aws_db_instance.example.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value = aws_db_instance.example.port
  description = "The port the database is listening on"
}

output "security_group_id" {
  value = length(aws_security_group.rds) > 0 ? aws_security_group.rds[0].id : null
  description = "Security group ID for the RDS instance (null for replicas)"
}

output "arn" {
  value = aws_db_instance.example.arn
  description = "RDS instance ARN"
}

output "identifier" {
  value = aws_db_instance.example.identifier
  description = "RDS instance identifier"
}


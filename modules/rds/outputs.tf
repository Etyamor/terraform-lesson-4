output "endpoint" {
  description = "Database connection endpoint"
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].endpoint
}

output "reader_endpoint" {
  description = "Aurora reader endpoint (Aurora only)"
  value       = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : null
}

output "port" {
  description = "Database port"
  value       = var.use_aurora ? aws_rds_cluster.this[0].port : aws_db_instance.this[0].port
}

output "db_name" {
  description = "Database name"
  value       = var.db_name
}

output "security_group_id" {
  description = "Security group ID for the database"
  value       = aws_security_group.this.id
}

output "subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.this.name
}

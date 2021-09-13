output "address" {
  description = "Database endpoint"
  value       = aws_db_instance.stage_mysql_db.address
}

output "port" {
  description = "Database port"
  value       = aws_db_instance.stage_mysql_db.port
}
output "endpoint" {
  description = "DNS address of RDS instance"
  value       = aws_db_instance.rds.address
}

output "port" {
  description = "Port on which the DB accepts connections"
  value       = aws_db_instance.rds.port
}

output "db_name" {
  description = "Name of the created DB"
  value       = aws_db_instance.rds.db_name
}

output "master_user_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret that contains DB credentials"
  value       = aws_db_instance.rds.master_user_secret[0].secret_arn
}

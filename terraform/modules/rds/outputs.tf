output "endpoint" {
  description = "DNS address of RDS instance"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "Port on which the DB accepts connections"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Name of the created DB"
  value       = aws_db_instance.this.db_name
}

output "master_user_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret that contains DB credentials"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

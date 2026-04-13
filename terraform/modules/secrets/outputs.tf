output "map_service_secret_arn" {
  description = "ARN of existing map-service secret"
  value       = data.aws_secretsmanager_secret.map_service.arn
}

output "db_password" {
  description = "Database password"
  value       = random_password.db.result
  sensitive   = true
}

output "db_secret_arn" {
  description = "ARN of the database secret"
  value       = aws_secretsmanager_secret.db.arn
}

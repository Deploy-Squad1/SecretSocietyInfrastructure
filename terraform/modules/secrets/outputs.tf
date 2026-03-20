output "map_service_secret_arn" {
  description = "ARN of map-service secret"
  value       = aws_secretsmanager_secret.map_service.arn
}

output "map_service_secret_arn" {
  description = "ARN of existing map-service secret"
  value       = data.aws_secretsmanager_secret.map_service.arn
}

output "map_service_secret_name" {
  value = aws_secretsmanager_secret.map_service.name
}

output "map_service_secret_arn" {
  value = aws_secretsmanager_secret.map_service.arn
}

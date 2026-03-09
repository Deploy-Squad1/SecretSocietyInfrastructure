resource "aws_secretsmanager_secret" "map_service" {
  name        = "secret-society/map-service"
  description = "Secrets for map-service"
}

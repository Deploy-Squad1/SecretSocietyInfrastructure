data "aws_secretsmanager_secret" "map_service" {
  name = "secret-society/map-service"
}

resource "random_password" "db" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "db" {
  name = "secret-society/db"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    DB_USER     = var.db_user
    DB_PASSWORD = random_password.db.result
    DB_HOST     = var.db_host
    DB_NAME     = var.db_name
    DB_PORT     = var.db_port
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

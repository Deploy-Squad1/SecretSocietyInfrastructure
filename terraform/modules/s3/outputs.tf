output "map_service_access_key_id" {
  value = aws_iam_access_key.map_service.id
}

output "map_service_secret_access_key" {
  value     = aws_iam_access_key.map_service.secret
  sensitive = true
}

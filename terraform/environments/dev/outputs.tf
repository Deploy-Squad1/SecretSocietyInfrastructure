output "master_user_secret_arn" {
  description = "ARN of the RDS master user secret"
  value       = module.rds.master_user_secret_arn
  sensitive   = true
}

output "rds_endpoint" {
  description = "DNS address of RDS instance"
  value       = module.rds.endpoint
}

output "rds_port" {
  description = "Port on which DB accepts connections"
  value       = module.rds.port
}

output "rds_db_name" {
  description = "Name of the created DB"
  value       = module.rds.db_name
}

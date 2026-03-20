output "rds_sg_id" {
  description = "Security group ID for RDS instance"
  value       = aws_security_group.rds.id
}

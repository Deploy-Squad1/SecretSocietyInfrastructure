output "rds_sg_id" {
  description = "Security group ID for RDS instance"
  value       = aws_security_group.rds.id
}

output "jenkins_sg_id" {
  description = "Security group ID for Jenkins server"
  value       = aws_security_group.jenkins.id
}

output "admin_host_sg_id" {
  description = "Security group ID for admin host"
  value       = aws_security_group.admin_host.id
}

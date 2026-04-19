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

output "db_secret_arn" {
  description = "ARN of database secret"
  value       = module.secrets.db_secret_arn
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_node_security_group_id" {
  description = "ID of the EKS node shared security group"
  value       = module.eks.node_security_group_id
}
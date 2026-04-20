variable "name" {
  description = "Base name used for security group resources"
}

variable "vpc_id" {
  description = "VPC ID where security groups are created"
}

variable "vpc_cidr" {
  description = "CIDR block of the VPS (temporary access for RDS)"
}

variable "db_port" {
  description = "DB port to allow inbound traffic"
  default     = 5432
}

variable "cluster_security_group_id" {
  description = "Security group ID of the EKS control plane"
  type        = string
}

variable "node_security_group_id" {
  description = "Security group ID of the EKS node group"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "team_user_arns" {
  description = "IAM users allowed to assume team role"
  type        = list(string)
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "ecr_repositories" {
  description = "List of ECR repositories"
  type        = list(string)
}

variable "eks_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
}

variable "node_instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
}

variable "node_min_size" {
  description = "Minimum number of EKS nodes"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of EKS nodes"
  type        = number
}

variable "node_desired_size" {
  description = "Desired number of EKS nodes"
  type        = number
}

variable "media_bucket_name" {
  description = "Name of the S3 bucket for media storage"
  type        = string
}

variable "media_allowed_origins" {
  description = "Allowed CORS origins for S3 bucket"
  type        = list(string)
}

variable "app_domain" {
  description = "FQDN for the application"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "rds_name" {
  description = "Name of the RDS instance"
  type        = string
}

variable "rds_instance_class" {
  description = "Instance class for RDS"
  type        = string
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot on RDS deletion"
  type        = bool
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection for RDS"
  type        = bool
}

variable "rds_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
}

variable "admin_instance_type" {
  description = "Instance type for admin host (SSM bastion)"
  type        = string
}

variable "jenkins_instance_type" {
  description = "Instance type for Jenkins EC2 instance"
  type        = string
}

variable "splunk_hec_endpoint" {
  description = "Splunk HEC endpoint URL used for log ingestion"
  type        = string
}

variable "splunk_hec_token" {
  description = "Authentication token for Splunk HEC"
  type        = string
  sensitive   = true
}

variable "splunk_observability_realm" {
  description = "Splunk Observability Cloud realm used for metrics ingestion"
  type        = string
}

variable "splunk_observability_access_token" {
  description = "Accesss token for Splunk obserability Cloud used by the collector to send metrics"
  type        = string
  sensitive   = true
}

variable "name" {
  description = "Identifier for RDS instance and its resources"
}

variable "subnet_ids" {
  description = "Private subnet IDs for DB subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs attached to RDS instance"
  type        = list(string)
}

variable "db_name" {
  description = "The DB name to create"
}

variable "username" {
  description = "Username for the master DB user"
}

variable "port" {
  description = "Database port"
  default     = 5432
}

variable "instance_class" {
  description = "RDS instance type"
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in GB"
  default     = 10
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  default     = 1
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
  default     = false
}

variable "deletion_protection" {
  description = "The DB can't be deleted when this value is set to true"
  default     = false
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  default     = false
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "create_map_service_secret" {
  description = "Whether to create map-service secret"
  type        = bool
  default     = true
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_host" {
  description = "Host address of the database"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "create_map_service_secret" {
  description = "Whether to create map-service secret"
  type        = bool
  default     = true
}

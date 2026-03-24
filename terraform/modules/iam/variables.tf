variable "user_name" {
  description = "The name of the IAM user"
  type        = string
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the user"
  type        = list(string)
  default     = []
}

variable "service_users" {
  description = "Service IAM users with access to S3 and Secrets Manager"
  type = map(object({
    bucket_name = string
    secret_arn  = string
  }))
  default = {}
}

variable "eks_admin_principals" {
  description = "Map of EKS admin principals allowed to assume dedicated roles"
  type = map(object({
    trusted_principal_arn = string
  }))
  default = {}
}

variable "admin_host_instance_arn" {
  description = "ARN of the admin host EC2 instance allowed for SSM sessions"
  type        = string
  default     = null
}

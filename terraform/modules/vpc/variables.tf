variable "name" {
  description = "Base name used for VPC and its resources"
  type        = string
}

variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

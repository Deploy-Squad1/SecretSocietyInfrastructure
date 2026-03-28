variable "cluster_name" {}
variable "cluster_endpoint" {}
variable "cluster_ca" {}

variable "image_repository" {
  description = "ECR repository for nginx gateway fabric"
  type        = string
}

variable "image_tag" {
  description = "Image tag"
  type        = string
  default     = "edge"
}

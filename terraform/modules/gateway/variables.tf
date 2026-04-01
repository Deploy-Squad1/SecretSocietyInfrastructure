variable "gateway_image_repository" {
  description = "ECR repository for nginx gateway fabric"
  type        = string
}

variable "gateway_image_tag" {
  description = "Image tag"
  type        = string
}

variable "nginx_image_repository" {
  description = "ECR repository for nginx dataplane"
  type        = string
}

variable "nginx_image_tag" {
  description = "Image tag for nginx dataplane"
  type        = string
  default     = "latest"
}

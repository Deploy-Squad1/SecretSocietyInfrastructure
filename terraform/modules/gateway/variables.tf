variable "gateway_image_repository" {
  description = "ECR repository for nginx gateway fabric"
  type        = string
}

variable "gateway_image_tag" {
  description = "Image tag"
  type        = string
}

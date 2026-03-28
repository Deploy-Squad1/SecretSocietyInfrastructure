variable "team_user_arns" {
  description = "List of IAM user ARNs allowed to assume team role"
  type        = list(string)
}

variable "image_repository" {
  description = "ECR repo URL used for the NGF controller image"
  type        = string
}

variable "image_tag" {
  description = "Image tag for the NGF controller"
  type        = string
}
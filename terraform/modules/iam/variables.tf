variable "user_name" {
  description = "The name of the IAM user"
  type        = string
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the user"
  type        = list(string)
  default     = []
}

variable "media_bucket_arn" {
  description = "ARN of the media S3 bucket"
  type        = string
}

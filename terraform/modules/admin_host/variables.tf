variable "env" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Private subnet ID where the admin EC2 instance will be deployed"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID for the EC2 instance"
  type        = string
}

variable "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  type        = string
}

variable "terraform_state_bucket_arn" {
  description = "ARN of the State bucket"
  type        = string
}

variable "env"{
    description = "Environment name (e.g., dev, staging, prod)"
    type        = string
}

variable "instance_type"{
    description = "EC2 instance type"
    type        = string
    default     = "t3.small"
}

variable "subnet_id"{
    description = "Subnet ID where the EC2 instance will be deployed"
    type        = string
}

variable "ami_id"{
    description = "AMI ID for the EC2 instance"
    type        = string
}

variable "security_group_id" {
    description = "Security Group ID for the EC2 instance"
    type        = string
}
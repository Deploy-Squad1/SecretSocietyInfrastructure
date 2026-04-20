# RDS Security Group
resource "aws_security_group" "rds" {
  name   = "${var.name}-rds-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Jenkins Security Group
resource "aws_security_group" "jenkins" {
  name        = "${var.name}-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bastion Security Group
resource "aws_security_group" "admin_host" {
  name        = "${var.name}-admin-host-sg"
  description = "Security group for admin host"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow Consul injector from EKS control plane to node group
resource "aws_security_group_rule" "node_group_consul_connect_injector" {
  type        = "ingress"
  description = "Allow Consul connect injector from EKS control plane"

  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"

  security_group_id        = var.node_security_group_id
  source_security_group_id = var.cluster_security_group_id
}

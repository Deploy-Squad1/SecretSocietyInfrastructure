data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# IAM role for admin host (SSM access)
resource "aws_iam_role" "admin_ssm_role" {
  name = "admin-ssm-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.admin_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "eks_access" {
  name = "admin-eks-access-${var.env}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = var.eks_cluster_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_access_attach" {
  role       = aws_iam_role.admin_ssm_role.name
  policy_arn = aws_iam_policy.eks_access.arn
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "admin_ssm_profile" {
  name = "admin-ssm-instance-profile-${var.env}"
  role = aws_iam_role.admin_ssm_role.name
}

# Admin EC2 instance (bastion via SSM)
resource "aws_instance" "admin_host" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.admin_ssm_profile.name

  user_data = <<-EOF
#!/bin/bash
snap install amazon-ssm-agent --classic
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
EOF

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name        = "admin-host-${var.env}"
    Environment = var.env
  }
}

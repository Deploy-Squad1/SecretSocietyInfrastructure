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
  name        = "admin-eks-access-${var.env}"
  description = "Allow admin EC2 to access EKS clusters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_access_attach" {
  role       = aws_iam_role.admin_ssm_role.name
  policy_arn = aws_iam_policy.eks_access.arn
}

resource "aws_iam_instance_profile" "admin_ssm_profile" {
  name = "admin-ssm-instance-profile-${var.env}"
  role = aws_iam_role.admin_ssm_role.name
}

resource "aws_instance" "admin_host" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.admin_ssm_profile.name

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name        = "admin-host-${var.env}"
    Environment = var.env
  }
}

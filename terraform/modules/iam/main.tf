data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# CI user (for GitHub Actions)
resource "aws_iam_user" "this" {
  name          = var.user_name
  force_destroy = true
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each = toset(var.policy_arns)

  user       = aws_iam_user.this.name
  policy_arn = each.value
}

# service users
resource "aws_iam_user" "service" {
  for_each = var.service_users

  name = each.key
}

resource "aws_iam_access_key" "service" {
  for_each = var.service_users

  user = aws_iam_user.service[each.key].name
}

resource "aws_iam_user_policy" "service_s3" {
  for_each = var.service_users

  name = "${each.key}-s3-access"
  user = aws_iam_user.service[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::${each.value.bucket_name}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::${each.value.bucket_name}"
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = each.value.secret_arn
      }
    ]
  })
}

# team role
resource "aws_iam_role" "team_access" {
  name = "team-access-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = tolist(var.team_user_arns)
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# EKS role
resource "aws_iam_role" "eks_admin" {
  name = "eks-admin-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.team_access.arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# allow team -> admin
resource "aws_iam_policy" "team_assume_eks_admin" {
  name = "team-assume-eks-admin-${var.env}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.eks_admin.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "team_assume_attach" {
  role       = aws_iam_role.team_access.name
  policy_arn = aws_iam_policy.team_assume_eks_admin.arn
}

resource "aws_iam_policy" "eks_admin_access" {
  name = "eks-admin-access-${var.env}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = var.eks_cluster_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_access_attach" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = aws_iam_policy.eks_admin_access.arn
}

resource "aws_iam_role_policy_attachment" "eks_admin_readonly_attach" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "eks_admin_ecr" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# S3 access for Terraform state
resource "aws_iam_policy" "eks_admin_s3_state_access" {
  name = "eks-admin-s3-state-${var.env}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::secret-society-tf-state-deploysquad"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::secret-society-tf-state-deploysquad/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_s3_state_attach" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = aws_iam_policy.eks_admin_s3_state_access.arn
}

# SSM access to admin host
resource "aws_iam_policy" "eks_admin_ssm_access" {
  name = "eks-admin-ssm-${var.env}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:ResumeSession",
          "ssm:TerminateSession"
        ]
        Resource = [
          var.admin_host_instance_arn,
          "arn:aws:ssm:${data.aws_region.current.region}::document/AWS-StartPortForwardingSessionToRemoteHost",
          "arn:aws:ssm:${data.aws_region.current.region}::document/SSM-SessionManagerRunShell"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeInstanceInformation"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_ssm_attach" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = aws_iam_policy.eks_admin_ssm_access.arn
}
  
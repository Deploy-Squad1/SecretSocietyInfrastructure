data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

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

# service users:
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

resource "aws_iam_role" "eks_admin" {
  for_each = var.eks_admin_principals

  name = "dev-eks-admin-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = each.value.trusted_principal_arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "eks_admin_access" {
  for_each = var.eks_admin_principals

  name        = "dev-eks-admin-${each.key}-eks-access"
  description = "Allow dedicated EKS admin role to describe EKS clusters"

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

resource "aws_iam_role_policy_attachment" "eks_admin_access" {
  for_each = var.eks_admin_principals

  role       = aws_iam_role.eks_admin[each.key].name
  policy_arn = aws_iam_policy.eks_admin_access[each.key].arn
}

resource "aws_iam_policy" "eks_admin_ssm_access" {
  for_each = var.eks_admin_principals

  name        = "dev-eks-admin-${each.key}-ssm-access"
  description = "Allow SSM port forwarding sessions"

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
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_ssm_access" {
  for_each = var.eks_admin_principals

  role       = aws_iam_role.eks_admin[each.key].name
  policy_arn = aws_iam_policy.eks_admin_ssm_access[each.key].arn
}
  
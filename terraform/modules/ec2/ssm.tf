resource "aws_iam_role" "ssm_role" {
  name = "jenkins-ssm-role-${var.env}"
  
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
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "jenkins-ssm-instance-profile-${var.env}"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_policy" "jenkins_eks_access" {
  name        = "jenkins-eks-access-${var.env}"
  description = "Allow Jenkins EC2 to access EKS clusters"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_eks_access_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.jenkins_eks_access.arn
}

resource "aws_iam_policy" "jenkins_assume_role" {
  name        = "jenkins-assume-cross-account-${var.env}"
  description = "Allow Jenkins to assume TerraformDeployRole in other accounts"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::*:role/TerraformDeployRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_assume_role_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.jenkins_assume_role.arn
}
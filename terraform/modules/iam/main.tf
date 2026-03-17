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

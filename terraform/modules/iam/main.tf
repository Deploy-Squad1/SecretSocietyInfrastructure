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

resource "aws_iam_user" "map_service" {
  name = "map-service"
}

resource "aws_iam_access_key" "map_service" {
  user = aws_iam_user.map_service.name
}

resource "aws_iam_user_policy" "map_service_s3" {
  name = "map-service-s3-access"
  user = aws_iam_user.map_service.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = "${var.media_bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = var.media_bucket_arn
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:eu-north-1:983988120210:secret:secret-society/map-service*"
      }
    ]
  })
}

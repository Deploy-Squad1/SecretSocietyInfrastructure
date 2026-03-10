resource "aws_s3_bucket" "media" {
  bucket = "secret-society-media-ds"
}

resource "aws_s3_bucket_public_access_block" "media" {
  bucket = aws_s3_bucket.media.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_cors_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  cors_rule {
    allowed_methods = ["PUT", "GET"]

    allowed_origins = [
      "http://localhost:5173"
    ]

    allowed_headers = [
      "Content-Type",
      "x-amz-date",
      "x-amz-content-sha256",
      "authorization",
      "x-amz-security-token"
    ]

    max_age_seconds = 3000
  }
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
        Resource = "${aws_s3_bucket.media.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.media.arn
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

variable "bucket_name" {
  type = string
}

variable "allowed_origins" {
  type    = list(string)
  default = []
}

resource "aws_s3_bucket" "media" {
  bucket = var.bucket_name
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
  count  = length(var.allowed_origins) > 0 ? 1 : 0
  bucket = aws_s3_bucket.media.id

  cors_rule {
    allowed_methods = ["PUT", "GET"]

    allowed_origins = var.allowed_origins

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

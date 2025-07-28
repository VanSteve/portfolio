# S3 Website Hosting Module
# This module creates an S3 bucket configured for static website hosting

# S3 Bucket for Static Website Hosting
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name
}

# Configure S3 Bucket to Allow Public Access
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

# Wait for S3 bucket settings to propagate
resource "time_sleep" "wait_for_bucket_settings" {
  depends_on = [
    aws_s3_bucket_public_access_block.website,
    aws_s3_bucket_website_configuration.website
  ]
  
  create_duration = "10s"
}

# S3 Bucket Policy for Public Read Access
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  
  # Explicit dependency to ensure public access block is configured first
  depends_on = [
    aws_s3_bucket_public_access_block.website,
    aws_s3_bucket_website_configuration.website,
    time_sleep.wait_for_bucket_settings
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      },
    ]
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "website" {
  count  = var.lifecycle_rules.enabled ? 1 : 0
  bucket = aws_s3_bucket.website.id

  rule {
    id     = "lifecycle_rule"
    status = "Enabled"

    filter {
      prefix = ""  # Apply to all objects
    }

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_rules.noncurrent_version_expiration
    }

    expiration {
      expired_object_delete_marker = var.lifecycle_rules.delete_markers_expiration
    }
  }

  depends_on = [aws_s3_bucket_versioning.website]
} 
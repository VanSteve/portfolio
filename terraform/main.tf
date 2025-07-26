# Portfolio Infrastructure - Main Configuration
# This file contains the core infrastructure resources for the portfolio website

terraform {
  cloud {
    organization = "vansteve-portfolio"
    
    workspaces {
      name = "portfolio-infrastructure"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = merge({
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner
    }, var.tags)
  }
}

# AWS Provider for us-east-1 (this region is required for ACM certificates used with CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  
  default_tags {
    tags = merge({
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner
    }, var.tags)
  }
}

# S3 Bucket for Static Website Hosting
resource "aws_s3_bucket" "portfolio_website" {
  bucket = var.website_bucket_name
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy for Public Read Access
resource "aws_s3_bucket_policy" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id
  depends_on = [aws_s3_bucket_public_access_block.portfolio_website]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.portfolio_website.arn}/*"
      },
    ]
  })
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio_website.id
  versioning_configuration {
    status = var.enable_s3_versioning ? "Enabled" : "Disabled"
  }
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "portfolio_website" {
  count  = var.s3_lifecycle_rules.enabled ? 1 : 0
  bucket = aws_s3_bucket.portfolio_website.id

  rule {
    id     = "lifecycle_rule"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.s3_lifecycle_rules.noncurrent_version_expiration
    }

    expiration {
      expired_object_delete_marker = var.s3_lifecycle_rules.delete_markers_expiration
    }
  }

  depends_on = [aws_s3_bucket_versioning.portfolio_website]
}

# S3 Bucket for CloudFront Logs (only if logging enabled)
resource "aws_s3_bucket" "cloudfront_logs" {
  count  = var.enable_cloudfront_logging ? 1 : 0
  bucket = "${var.website_bucket_name}-cloudfront-logs"
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  count  = var.enable_cloudfront_logging ? 1 : 0
  bucket = aws_s3_bucket.cloudfront_logs[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudfront_logs" {
  count      = var.enable_cloudfront_logging ? 1 : 0
  depends_on = [aws_s3_bucket_ownership_controls.cloudfront_logs]
  bucket     = aws_s3_bucket.cloudfront_logs[0].id
  acl        = "private"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "portfolio_website" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.portfolio_website.website_endpoint
    origin_id   = "S3-${aws_s3_bucket.portfolio_website.bucket}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Portfolio Website Distribution"
  default_root_object = "index.html"

  aliases = var.domain_name != "" ? [var.domain_name] : []

  # CloudFront Logging Configuration (optional)
  dynamic "logging_config" {
    for_each = var.enable_cloudfront_logging ? [1] : []
    content {
      include_cookies = false
      bucket          = aws_s3_bucket.cloudfront_logs[0].bucket_domain_name
      prefix          = "cloudfront-logs/"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.portfolio_website.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  price_class = var.cloudfront_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "Portfolio Website Distribution"
  }

  viewer_certificate {
    cloudfront_default_certificate = var.domain_name == "" ? true : false
    acm_certificate_arn           = var.domain_name != "" ? aws_acm_certificate.portfolio_cert[0].arn : null
    ssl_support_method            = var.domain_name != "" ? "sni-only" : null
    minimum_protocol_version      = var.domain_name != "" ? "TLSv1.2_2021" : null
  }
}

# ACM Certificate (only if domain_name is provided)
# NOTE: ACM certificates for CloudFront MUST be created in us-east-1
resource "aws_acm_certificate" "portfolio_cert" {
  count             = var.domain_name != "" ? 1 : 0
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name = "Portfolio Website Certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route53 Hosted Zone (only if domain_name is provided)
resource "aws_route53_zone" "portfolio" {
  count = var.domain_name != "" ? 1 : 0
  name  = var.domain_name

  tags = {
    Name = "Portfolio Website Hosted Zone"
  }
}

# Route53 Record for CloudFront Distribution (only if domain_name is provided)
resource "aws_route53_record" "portfolio" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = aws_route53_zone.portfolio[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portfolio_website.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio_website.hosted_zone_id
    evaluate_target_health = false
  }
} 
# CloudFront Distribution Module
# This module creates a CloudFront distribution with SSL certificate and optional Route53 configuration

# S3 Bucket for CloudFront Logs (only if logging enabled)
resource "aws_s3_bucket" "cloudfront_logs" {
  count  = var.enable_logging ? 1 : 0
  bucket = "${var.s3_bucket_name}-cloudfront-logs"
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.cloudfront_logs[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudfront_logs" {
  count      = var.enable_logging ? 1 : 0
  depends_on = [aws_s3_bucket_ownership_controls.cloudfront_logs]
  bucket     = aws_s3_bucket.cloudfront_logs[0].id
  acl        = "private"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = var.origin_domain_name
    origin_id   = var.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.comment
  default_root_object = var.default_root_object

  # TEMPORARILY DISABLED - Enable after IONOS name servers are updated
  # aliases = var.domain_name != "" ? [var.domain_name] : []

  # CloudFront Logging Configuration (optional)
  dynamic "logging_config" {
    for_each = var.enable_logging ? [1] : []
    content {
      include_cookies = false
      bucket          = aws_s3_bucket.cloudfront_logs[0].bucket_domain_name
      prefix          = "cloudfront-logs/"
    }
  }

  default_cache_behavior {
    allowed_methods  = var.cache_behavior.allowed_methods
    cached_methods   = var.cache_behavior.cached_methods
    target_origin_id = var.origin_id

    forwarded_values {
      query_string = var.cache_behavior.query_string
      cookies {
        forward = var.cache_behavior.cookies_forward
      }
    }

    viewer_protocol_policy = var.cache_behavior.viewer_protocol_policy
    min_ttl                = var.cache_behavior.min_ttl
    default_ttl            = var.cache_behavior.default_ttl
    max_ttl                = var.cache_behavior.max_ttl
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code         = custom_error_response.value.error_code
      response_code      = custom_error_response.value.response_code
      response_page_path = custom_error_response.value.response_page_path
    }
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.restriction_type
      locations        = var.geo_restriction.locations
    }
  }

  tags = var.tags

  # Use default CloudFront certificate temporarily
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # TEMPORARILY DISABLED - Enable after IONOS name servers are updated
  # # Conditional viewer certificate configuration
  # dynamic "viewer_certificate" {
  #   for_each = var.domain_name == "" ? [1] : []
  #   content {
  #     cloudfront_default_certificate = true
  #   }
  # }

  # dynamic "viewer_certificate" {
  #   for_each = var.domain_name != "" ? [1] : []
  #   content {
  #     acm_certificate_arn      = aws_acm_certificate.cert[0].arn  # Use unvalidated cert temporarily
  #     ssl_support_method       = "sni-only"
  #     minimum_protocol_version = var.minimum_protocol_version
  #   }
  # }
}

# ACM Certificate (only if domain_name is provided)
# NOTE: ACM certificates for CloudFront MUST be created in us-east-1
resource "aws_acm_certificate" "cert" {
  count             = var.domain_name != "" ? 1 : 0
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = merge(var.tags, {
    Name = "${var.domain_name} Certificate"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Route53 record for ACM certificate validation
# TEMPORARILY DISABLED - Enable after updating IONOS name servers
# resource "aws_route53_record" "cert_validation" {
#   for_each = var.domain_name != "" ? {
#     for dvo in aws_acm_certificate.cert[0].domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   } : {}

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = var.create_route53_zone ? aws_route53_zone.zone[0].zone_id : var.route53_zone_id

#   depends_on = [aws_route53_zone.zone]
# }

# ACM certificate validation
# TEMPORARILY DISABLED - Enable after updating IONOS name servers
# resource "aws_acm_certificate_validation" "cert" {
#   count                   = var.domain_name != "" ? 1 : 0
#   provider                = aws.us_east_1
#   certificate_arn         = aws_acm_certificate.cert[0].arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

#   depends_on = [aws_route53_record.cert_validation]

#   timeouts {
#     create = "10m"
#   }
# }

# Route53 Hosted Zone (only if domain_name is provided and create_route53_zone is true)
resource "aws_route53_zone" "zone" {
  count = var.domain_name != "" && var.create_route53_zone ? 1 : 0
  name  = var.domain_name

  tags = merge(var.tags, {
    Name = "${var.domain_name} Hosted Zone"
  })
}

# Route53 Record for CloudFront Distribution (only if domain_name is provided)
# TEMPORARILY DISABLED - Enable after IONOS name servers are updated
# resource "aws_route53_record" "record" {
#   count   = var.domain_name != "" ? 1 : 0
#   zone_id = var.create_route53_zone ? aws_route53_zone.zone[0].zone_id : var.route53_zone_id
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.distribution.domain_name
#     zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
#     evaluate_target_health = false
#   }
# } 
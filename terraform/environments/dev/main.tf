# Portfolio Infrastructure - Development Environment
# This configuration uses the S3 and CloudFront modules for the dev environment

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

# AWS Provider for us-east-1 (required for ACM certificates used with CloudFront)
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

# S3 Website Hosting Module
module "s3_website" {
  source = "../../modules/s3-website"
  
  bucket_name      = "${var.website_bucket_name}-${var.environment}-${var.aws_region}"
  index_document   = var.index_document
  error_document   = var.error_document
  enable_versioning = var.enable_s3_versioning
  lifecycle_rules   = var.s3_lifecycle_rules
  
  tags = merge(var.tags, {
    Module = "s3-website"
  })
}

# CloudFront Distribution Module
module "cloudfront" {
  source = "../../modules/cloudfront"
  
  providers = {
    aws.us_east_1 = aws.us_east_1
  }
  
  s3_bucket_name          = module.s3_website.bucket_name
  origin_domain_name      = module.s3_website.website_endpoint
  origin_id               = "S3-${module.s3_website.bucket_name}"
  domain_name             = var.domain_name
  comment                 = "Portfolio Website Distribution - ${var.environment}"
  default_root_object     = var.index_document
  enable_logging          = var.enable_cloudfront_logging
  price_class             = var.cloudfront_price_class
  minimum_protocol_version = var.minimum_protocol_version
  create_route53_zone     = var.create_route53_zone
  route53_zone_id         = var.route53_zone_id
  
  cache_behavior = {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    query_string           = false
    cookies_forward        = "none"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  
  custom_error_responses = [
    {
      error_code         = 404
      response_code      = 404
      response_page_path = "/404.html"
    }
  ]
  
  geo_restriction = {
    restriction_type = "none"
    locations        = []
  }
  
  tags = merge(var.tags, {
    Module = "cloudfront"
  })
} 
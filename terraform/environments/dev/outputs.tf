# Portfolio Infrastructure - Development Environment Outputs
# Output values from the dev environment infrastructure

output "website_url" {
  description = "Complete website URL"
  value       = module.cloudfront.website_url
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for cache management"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.distribution_domain_name
}

output "website_bucket_name" {
  description = "S3 bucket name for content uploads"
  value       = module.s3_website.bucket_name
}

output "website_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3_website.bucket_arn
}

output "certificate_arn" {
  description = "ACM certificate ARN (if custom domain is used)"
  value       = module.cloudfront.certificate_arn
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID (if custom domain is used)"
  value       = module.cloudfront.route53_zone_id
}

output "route53_name_servers" {
  description = "Route53 name servers for domain configuration (if custom domain is used)"
  value       = module.cloudfront.route53_name_servers
} 
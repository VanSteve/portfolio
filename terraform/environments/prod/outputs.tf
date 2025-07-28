# Portfolio Infrastructure - Output Values
# This file defines outputs that will be available after Terraform applies

output "website_bucket_name" {
  description = "Name of the S3 bucket hosting the website"
  value       = module.s3_website.bucket_name
}

output "website_bucket_arn" {
  description = "ARN of the S3 bucket hosting the website"
  value       = module.s3_website.bucket_arn
}

output "website_bucket_domain_name" {
  description = "Bucket domain name for the website"
  value       = module.s3_website.bucket_domain_name
}

output "website_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = module.s3_website.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "Website endpoint URL"
  value       = module.s3_website.website_endpoint
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = module.cloudfront.distribution_arn
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.cloudfront.distribution_domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution"
  value       = module.cloudfront.distribution_hosted_zone_id
}

output "website_url" {
  description = "Complete website URL"
  value       = module.cloudfront.website_url
}

# Certificate outputs (only if custom domain is used)
output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = module.cloudfront.certificate_arn
}

output "certificate_domain_name" {
  description = "Domain name of the ACM certificate"
  value       = var.domain_name != "" ? var.domain_name : null
}

# Route53 outputs (only if custom domain is used)
output "route53_zone_id" {
  description = "Zone ID of the Route53 hosted zone"
  value       = module.cloudfront.route53_zone_id
}

output "route53_name_servers" {
  description = "Name servers for the Route53 hosted zone"
  value       = module.cloudfront.route53_name_servers
}

# Infrastructure metadata
output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "deployment_timestamp" {
  description = "Timestamp of the deployment"
  value       = timestamp()
}

# CloudFront Logs outputs (only if logging is enabled)
output "cloudfront_logs_bucket_name" {
  description = "Name of the CloudFront logs S3 bucket"
  value       = module.cloudfront.cloudfront_logs_bucket_name
}

output "cloudfront_logs_bucket_arn" {
  description = "ARN of the CloudFront logs S3 bucket"
  value       = var.enable_cloudfront_logging ? "${module.s3_website.bucket_arn}-cloudfront-logs" : null
} 
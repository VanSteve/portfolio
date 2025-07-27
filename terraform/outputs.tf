# Portfolio Infrastructure - Output Values
# This file defines outputs that will be available after Terraform applies

output "website_bucket_name" {
  description = "Name of the S3 bucket hosting the website"
  value       = aws_s3_bucket.portfolio_website.id
}

output "website_bucket_arn" {
  description = "ARN of the S3 bucket hosting the website"
  value       = aws_s3_bucket.portfolio_website.arn
}

output "website_bucket_domain_name" {
  description = "Bucket domain name for the website"
  value       = aws_s3_bucket.portfolio_website.bucket_domain_name
}

output "website_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.portfolio_website.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "Website endpoint URL"
  value       = aws_s3_bucket_website_configuration.portfolio_website.website_endpoint
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.portfolio_website.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.portfolio_website.arn
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.portfolio_website.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.portfolio_website.hosted_zone_id
}

output "website_url" {
  description = "Complete website URL"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "https://${aws_cloudfront_distribution.portfolio_website.domain_name}"
}

# Certificate outputs (only if custom domain is used)
output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = var.domain_name != "" ? aws_acm_certificate.portfolio_cert[0].arn : null
}

output "certificate_domain_name" {
  description = "Domain name of the ACM certificate"
  value       = var.domain_name != "" ? aws_acm_certificate.portfolio_cert[0].domain_name : null
}

# Route53 outputs (only if custom domain is used)
output "route53_zone_id" {
  description = "Zone ID of the Route53 hosted zone"
  value       = var.domain_name != "" ? aws_route53_zone.portfolio[0].zone_id : null
}

output "route53_name_servers" {
  description = "Name servers for the Route53 hosted zone"
  value       = var.domain_name != "" ? aws_route53_zone.portfolio[0].name_servers : null
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
  value       = var.enable_cloudfront_logging ? aws_s3_bucket.cloudfront_logs[0].id : null
}

output "cloudfront_logs_bucket_arn" {
  description = "ARN of the CloudFront logs S3 bucket"
  value       = var.enable_cloudfront_logging ? aws_s3_bucket.cloudfront_logs[0].arn : null
} 
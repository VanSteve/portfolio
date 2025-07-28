# CloudFront Distribution Module - Outputs
# Output values from the CloudFront distribution module

output "distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.id
}

output "distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.arn
}

output "distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.domain_name
}

output "distribution_hosted_zone_id" {
  description = "Hosted zone ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.hosted_zone_id
}

output "website_url" {
  description = "Complete website URL"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "https://${aws_cloudfront_distribution.distribution.domain_name}"
}

output "certificate_arn" {
  description = "ARN of the ACM certificate (if created)"
  value       = var.domain_name != "" ? aws_acm_certificate.cert[0].arn : null
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID (if created)"
  value       = var.domain_name != "" && var.create_route53_zone ? aws_route53_zone.zone[0].zone_id : null
}

output "route53_name_servers" {
  description = "Route53 name servers (if zone is created)"
  value       = var.domain_name != "" && var.create_route53_zone ? aws_route53_zone.zone[0].name_servers : null
}

output "cloudfront_logs_bucket_name" {
  description = "Name of the CloudFront logs S3 bucket (if created)"
  value       = var.enable_logging ? aws_s3_bucket.cloudfront_logs[0].bucket : null
} 
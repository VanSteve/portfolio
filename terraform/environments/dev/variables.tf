# Portfolio Infrastructure - Development Environment Variables
# Variable definitions for the dev environment

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-west-2"
  
  validation {
    condition = can(regex("^(us|eu|ap|sa|ca|me|af)-[a-z]+-[0-9]{1,2}$", var.aws_region))
    error_message = "AWS region must be in the format: us-west-2, eu-west-1, etc."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "website_bucket_name" {
  description = "Base name of the S3 bucket for website hosting"
  type        = string
  default     = "portfolio-dev"
  
  validation {
    condition = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.website_bucket_name)) && length(var.website_bucket_name) >= 3 && length(var.website_bucket_name) <= 45
    error_message = "S3 bucket base name must be 3-45 characters, lowercase letters, numbers, and hyphens only."
  }
}

variable "domain_name" {
  description = "Custom domain name for the website (optional)"
  type        = string
  default     = ""
  
  validation {
    condition = var.domain_name == "" || can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.domain_name))
    error_message = "Domain name must be a valid FQDN or empty string."
  }
}

variable "project_name" {
  description = "Name of the project for resource tagging"
  type        = string
  default     = "portfolio"
}

variable "owner" {
  description = "Owner of the resources for tagging"
  type        = string
  default     = "dev-team"
}

variable "index_document" {
  description = "Index document for the website"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for the website"
  type        = string
  default     = "404.html"
}

variable "enable_s3_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "s3_lifecycle_rules" {
  description = "S3 bucket lifecycle configuration"
  type = object({
    enabled                        = bool
    noncurrent_version_expiration  = number
    delete_markers_expiration      = bool
  })
  default = {
    enabled                        = true
    noncurrent_version_expiration  = 30
    delete_markers_expiration      = true
  }
}

variable "enable_cloudfront_logging" {
  description = "Enable CloudFront access logging"
  type        = bool
  default     = false
}

variable "cloudfront_price_class" {
  description = "Price class for the CloudFront distribution"
  type        = string
  default     = "PriceClass_100"
  
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "Price class must be one of: PriceClass_All, PriceClass_200, PriceClass_100."
  }
}

variable "minimum_protocol_version" {
  description = "Minimum SSL/TLS protocol version for HTTPS connections"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "create_route53_zone" {
  description = "Whether to create a new Route53 hosted zone"
  type        = bool
  default     = true
}

variable "route53_zone_id" {
  description = "Existing Route53 zone ID (required if create_route53_zone is false and domain_name is set)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    Terraform   = "true"
  }
} 
# Portfolio Infrastructure - Variable Definitions
# This file defines all input variables for the Terraform Cloud workspace

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
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "website_bucket_name" {
  description = "Base name of the S3 bucket for website hosting (region will be appended automatically)"
  type        = string
  
  validation {
    condition = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.website_bucket_name)) && length(var.website_bucket_name) >= 3 && length(var.website_bucket_name) <= 45
    error_message = "S3 bucket base name must be 3-45 characters, lowercase letters, numbers, and hyphens only (region suffix will be added)."
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
  description = "Owner of the infrastructure for resource tagging"
  type        = string
  default     = "VanSteve"
}

variable "enable_cloudfront_logging" {
  description = "Enable CloudFront access logging"
  type        = bool
  default     = false
}

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
  
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "CloudFront price class must be one of: PriceClass_All, PriceClass_200, PriceClass_100."
  }
}

variable "enable_s3_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "s3_lifecycle_rules" {
  description = "S3 bucket lifecycle rules configuration"
  type = object({
    enabled                       = bool
    noncurrent_version_expiration = number
    delete_markers_expiration     = bool
  })
  default = {
    enabled                       = true
    noncurrent_version_expiration = 90
    delete_markers_expiration     = true
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
} 
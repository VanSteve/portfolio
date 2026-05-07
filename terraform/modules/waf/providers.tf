# WAF Module - Provider Requirements
# This module must be called with the us-east-1 provider because WAF Web ACLs
# used with CloudFront must reside in us-east-1.

terraform {
  required_version = ">= 1.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

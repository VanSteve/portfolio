# Portfolio Infrastructure - Terraform Configuration
# This file specifies Terraform version and provider requirements

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
} 
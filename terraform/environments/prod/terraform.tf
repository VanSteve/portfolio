# Portfolio Infrastructure - Terraform Configuration
# This file specifies Terraform version, provider requirements, and backend configuration

terraform {
  cloud {
    organization = "vansteve-portfolio"
    
    workspaces {
      name = "portfolio-infrastructure-prod"
    }
  }
  
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
# Portfolio Infrastructure - Development Environment Backend
# Terraform Cloud backend configuration for the dev environment

terraform {
  cloud {
    organization = "vansteve-portfolio"
    
    workspaces {
      name = "portfolio-infrastructure-dev"
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
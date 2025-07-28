# Portfolio Infrastructure

This directory contains the Terraform configuration for the portfolio website infrastructure, organized using a modular approach with environment-specific configurations managed through Terraform Cloud.

## 🏗️ Architecture Overview

The infrastructure provides:
- **S3 Bucket**: Static website hosting with public read access
- **CloudFront Distribution**: Global CDN with HTTPS redirect and caching
- **ACM Certificate**: SSL/TLS certificate for custom domains (optional)
- **Route53**: DNS management for custom domains (optional)

## 🌍 Environment Management

### Production Environment (`environments/prod/`)
- **Workspace**: `portfolio-infrastructure-prod`
- **Purpose**: Live production website
- **Configuration**: Production-optimized settings
- **Domain**: Production domain with SSL certificate
- **Logging**: Enabled for monitoring
- **Retention**: 90-day S3 version retention

### Staging Environment (`environments/staging/`)
- **Workspace**: `portfolio-infrastructure-staging`
- **Purpose**: Pre-production testing and validation
- **Configuration**: Production-like with cost optimizations
- **Domain**: Staging subdomain (optional)
- **Logging**: Enabled for testing
- **Retention**: 30-day S3 version retention

### Development Environment (`environments/dev/`)
- **Workspace**: `portfolio-infrastructure-dev`
- **Purpose**: Development and experimentation
- **Configuration**: Cost-optimized for development
- **Domain**: CloudFront URL (no custom domain)
- **Logging**: Disabled to reduce costs
- **Retention**: 7-day S3 version retention

## 🚀 Deployment Workflow

### 1. Development
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### 2. Staging
```bash
cd terraform/environments/staging
terraform init
terraform plan
terraform apply
```

### 3. Production
```bash
cd terraform/environments/prod
terraform init
terraform plan
terraform apply
```

## 🔧 Module Development

### Testing Modules Locally
```bash
# Test S3 website module
cd terraform/modules/s3-website
terraform init -backend=false
terraform validate

# Test CloudFront module
cd terraform/modules/cloudfront
terraform init -backend=false
terraform validate
```

### Adding New Environments
1. Copy an existing environment directory
2. Update `backend.tf` with new workspace name
3. Modify `variables.tf` defaults for the environment
4. Customize `terraform.tfvars` with appropriate settings
5. Update `README.md` with environment-specific information

## 📊 Terraform Cloud Workspaces

All environments are managed through separate Terraform Cloud workspaces:

| Environment | Workspace Name | Directory |
|-------------|----------------|-----------|
| Production | `portfolio-infrastructure-prod` | `terraform/environments/prod/` |
| Staging | `portfolio-infrastructure-staging` | `terraform/environments/staging/` |
| Development | `portfolio-infrastructure-dev` | `terraform/environments/dev/` |

### Workspace Configuration
Each workspace requires:
- AWS credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- Working directory set to the appropriate environment path
- Environment-specific variable overrides as needed

## 🔐 Security & Best Practices

### Module Design
- **Reusable**: Modules can be used across all environments
- **Configurable**: Environment-specific parameters via variables
- **Validated**: Input validation for all critical parameters
- **Documented**: Comprehensive variable and output documentation

### Environment Isolation
- **Separate State**: Each environment has its own Terraform state
- **Independent Deployment**: Environments can be deployed independently
- **Resource Isolation**: No cross-environment resource dependencies
- **Access Control**: Terraform Cloud workspace-level access control

### Infrastructure as Code
- **Version Control**: All configuration stored in Git
- **Automated Planning**: Pull request triggers plan generation
- **Approval Workflow**: Production deployments require approval
- **Rollback Capability**: S3 versioning enables content rollback

## 🐛 Troubleshooting

### Common Issues
- **Module Path**: Ensure module sources use relative paths (`../../modules/`)
- **Workspace Names**: Verify Terraform Cloud workspace names match
- **Variables**: Ensure all required variables are defined

### Validation Commands
```bash
# Validate configuration
terraform validate

# Check formatting
terraform fmt -check

# Initialize and get modules
terraform init
terraform get
```

## 📚 References

- [Terraform Cloud Workspaces](https://app.terraform.io)
- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [Route53 DNS Management](https://docs.aws.amazon.com/route53/)

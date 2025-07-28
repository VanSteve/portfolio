# Portfolio Infrastructure - Development Environment

This directory contains the Terraform configuration for the **development environment** of the portfolio website infrastructure. It uses modular Terraform configuration to deploy S3 + CloudFront infrastructure.

## 🏗️ Architecture

This environment uses the following modules:
- **S3 Website Module** (`../../modules/s3-website/`) - Static website hosting
- **CloudFront Module** (`../../modules/cloudfront/`) - CDN, SSL certificates, and DNS

## 🚀 Deployment

### Prerequisites
1. Terraform Cloud account with `vansteve-portfolio` organization
2. AWS credentials configured in Terraform Cloud workspace
3. Terraform CLI installed locally (for development)

### Terraform Cloud Workspace Setup
1. Create workspace named: `portfolio-infrastructure-dev`
2. Connect to this repository
3. Set working directory to: `terraform/environments/dev`
4. Configure environment variables:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_DEFAULT_REGION` (optional)

### Local Development
```bash
# Navigate to dev environment
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes (via Terraform Cloud)
terraform apply
```

## 🔧 Configuration

### Key Variables
- `website_bucket_name`: Base name for S3 bucket (default: `portfolio-dev`)
- `domain_name`: Custom domain (leave empty for CloudFront URL only)
- `aws_region`: AWS region for deployment (default: `us-west-2`)

### Environment-Specific Settings
- **S3 Versioning**: Enabled with 7-day retention for non-current versions
- **CloudFront Logging**: Disabled to reduce costs
- **Price Class**: `PriceClass_100` (most cost-effective)
- **Tags**: Environment-specific tags for cost tracking

## 📊 Outputs

After deployment:
- `website_url`: Complete website URL
- `cloudfront_distribution_id`: For cache invalidation
- `website_bucket_name`: For content uploads
- `route53_name_servers`: DNS configuration (if using custom domain)

## 💡 Development Tips

1. **Cost Optimization**: This environment is configured for minimal costs
2. **Quick Iteration**: Use CloudFront URL for development (no DNS setup required)
3. **Content Updates**: Upload files directly to the S3 bucket
4. **Cache Management**: Use the distribution ID for invalidations

## 🔄 Workflow

1. Make infrastructure changes in module files
2. Test in this dev environment first
3. Commit changes to trigger Terraform Cloud plan
4. Review and apply changes
5. Validate functionality before promoting to production 
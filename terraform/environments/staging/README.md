# Portfolio Infrastructure - Staging Environment

This directory contains the Terraform configuration for the **staging environment** of the portfolio website infrastructure. It uses modular Terraform configuration to deploy S3 + CloudFront infrastructure.

## 🏗️ Architecture

This environment uses the following modules:
- **S3 Website Module** (`../../modules/s3-website/`) - Static website hosting
- **CloudFront Module** (`../../modules/cloudfront/`) - CDN, SSL certificates, and DNS

## 🚀 Deployment

### Prerequisites
1. Terraform Cloud account with `vansteve-portfolio` organization
2. AWS credentials configured in Terraform Cloud workspace
3. Repository access for VCS-driven workflow

### Terraform Cloud Workspace Setup
1. Create workspace named: `portfolio-infrastructure-staging`
2. **Connect to this repository** (VCS-driven)
3. Set working directory to: `terraform/environments/staging`
4. Configure environment variables:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_DEFAULT_REGION` (optional)

### VCS-Driven Workflow
The staging environment uses **VCS-driven deployment**:

1. **Development**:
   ```bash
   # Create feature branch
   git checkout -b feature/your-changes
   
   # Make infrastructure changes
   # Edit terraform files as needed
   
   # Commit and push
   git add .
   git commit -m "Infrastructure changes"
   git push origin feature/your-changes
   ```

2. **Pull Request Process**:
   - Create PR from feature branch to `main`
   - **Terraform plan runs automatically** on staging as PR check
   - Review plan output in PR checks
   - Address any issues and push updates

3. **Deployment**:
   - **Merge PR to `main`** → **Staging auto-deploys immediately**
   - Monitor deployment in Terraform Cloud UI

### Local Planning (Optional)
```bash
# Navigate to staging environment (for local review only)
cd terraform/environments/staging

# Initialize Terraform (for local development)
terraform init

# Plan changes (local review - does not deploy)
terraform plan
```

## 🔧 Configuration

### Key Variables
- `website_bucket_name`: Base name for S3 bucket (default: `portfolio-staging`)
- `domain_name`: Custom domain (leave empty for CloudFront URL only)
- `aws_region`: AWS region for deployment (default: `us-west-2`)

### Environment-Specific Settings
- **S3 Versioning**: Enabled with 30-day retention for non-current versions
- **CloudFront Logging**: Enabled for testing
- **Price Class**: `PriceClass_100` (cost-effective for staging)
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
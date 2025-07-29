# Portfolio Infrastructure - Production Environment

This directory contains the Terraform configuration for the **production environment** of the portfolio website infrastructure. It uses modular Terraform configuration to deploy S3 + CloudFront infrastructure.

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
1. **Workspace Name**: `portfolio-infrastructure-prod`
2. **Connect to this repository** (VCS-driven)
3. Set working directory to: `terraform/environments/prod`
4. Configure environment variables:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_DEFAULT_REGION` (optional)

### VCS-Driven Workflow
The production environment uses **VCS-driven deployment**:

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
   - **Terraform plan runs automatically** on both staging AND production as PR checks
   - Review plan output in PR checks for both environments
   - Address any issues and push updates

3. **Deployment**:
   - **Merge PR to `main`** → **Both staging AND production auto-deploy immediately**
   - Monitor deployment in Terraform Cloud UI
   - **Note**: Currently both environments deploy on merge (this may change in future)

### Local Planning (Optional)
```bash
# Navigate to prod environment (for local review only)
cd terraform/environments/prod

# Initialize Terraform (for local development)
terraform init

# Plan changes (local review - does not deploy)
terraform plan

# For domain setup: Set domain_name variable in Terraform Cloud workspace UI
```

## 🔧 Configuration

### Key Variables
- `website_bucket_name`: Base name for S3 bucket (default: `portfolio-prod`)
- `domain_name`: **Production custom domain** (e.g., `fitzs.io`) - **Required for production**
- `aws_region`: AWS region for deployment (default: `us-west-2`)

### Production-Specific Settings
- **S3 Versioning**: Enabled with 90-day retention for production data protection
- **CloudFront Logging**: Enabled for production monitoring and analytics
- **Price Class**: `PriceClass_All` for global performance
- **SSL Certificate**: Automatic via ACM with DNS validation
- **Route 53**: Hosted zone and DNS records automatically configured

## 📊 Outputs

After deployment:
- `website_url`: Production website URL (https://fitzs.io)
- `cloudfront_distribution_id`: For cache invalidation
- `website_bucket_name`: For content uploads
- `route53_name_servers`: **For domain registrar configuration**
- `route53_zone_id`: Route 53 hosted zone ID
- `certificate_arn`: SSL certificate ARN

## 🔒 Production Considerations

1. **Domain Configuration**: Set `domain_name` variable for production domain
2. **SSL Certificates**: Automatic provisioning and renewal via ACM
3. **Monitoring**: Consider enabling CloudFront logging for production
4. **Backup**: S3 versioning enabled for content rollback capability
5. **Performance**: Configure appropriate CloudFront price class for global reach

## 🔄 Workflow

1. **Development**: Test changes in dev environment first
2. **Staging**: Validate in staging environment
3. **Production**: Deploy via Terraform Cloud with proper approvals
4. **Monitoring**: Monitor deployment and validate functionality

## ⚠️ Important Notes

- **DNS Propagation**: Allow 24-48 hours for DNS changes to propagate globally
- **Cache Invalidation**: Use CloudFront distribution ID for cache management
- **SSL Certificate**: Automatic validation via DNS records in Route53
- **Backup Strategy**: Leverage S3 versioning and cross-region replication if needed

## 🎯 Production Checklist

- [ ] Configure production domain name
- [ ] Set up monitoring and alerting
- [ ] Configure backup and disaster recovery
- [ ] Review security settings and IAM policies
- [ ] Set up content deployment pipeline
- [ ] Configure CloudFront logging (if required)
- [ ] Test SSL certificate and HTTPS redirect
- [ ] Validate global content delivery performance 
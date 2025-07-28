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
3. Terraform CLI installed locally (for development)

### Terraform Cloud Workspace Setup
1. **Workspace Name**: `portfolio-infrastructure-prod`
2. Connect to this repository
3. Set working directory to: `terraform/environments/prod`
4. Configure environment variables:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_DEFAULT_REGION` (optional)

### Local Development
```bash
# Navigate to prod environment
cd terraform/environments/prod

# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes (via Terraform Cloud)
terraform apply
```

## 🔧 Configuration

### Key Variables
- `website_bucket_name`: Base name for S3 bucket
- `domain_name`: Custom domain (configure for production domain)
- `aws_region`: AWS region for deployment (default: `us-west-2`)

### Production-Specific Settings
- **S3 Versioning**: Enabled with production-appropriate retention
- **CloudFront Logging**: Can be enabled for production monitoring
- **Price Class**: Configurable based on global requirements
- **SSL Certificate**: Production domain certificate with DNS validation

## 📊 Outputs

After deployment:
- `website_url`: Complete production website URL
- `cloudfront_distribution_id`: For cache invalidation
- `website_bucket_name`: For content uploads
- `route53_name_servers`: DNS configuration (if using custom domain)

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
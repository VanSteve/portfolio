# Portfolio Infrastructure

This directory contains the Terraform configuration for the portfolio website infrastructure, managed through Terraform Cloud with automated deployments via GitHub Actions.

## 🏗️ Architecture Overview

The infrastructure provides:
- **S3 Bucket**: Static website hosting with public read access
- **CloudFront Distribution**: Global CDN with HTTPS redirect and caching
- **ACM Certificate**: SSL/TLS certificate for custom domains (optional)
- **Route53**: DNS management for custom domains (optional)

## 🌍 Domain Configuration

### Current Setup
The infrastructure supports both CloudFront-only and custom domain deployments:

**Without Custom Domain:**
- Accessible via CloudFront distribution domain
- Format: `https://d123456789abcdef.cloudfront.net`

**With Custom Domain:**
- Set `domain_name` variable in Terraform Cloud workspace
- Route53 automatically manages DNS records
- ACM certificate handles SSL/TLS with automatic validation

### DNS Management
When using a custom domain:
1. Terraform creates Route53 hosted zone
2. Certificate validation occurs automatically via DNS
3. Update domain registrar to use Route53 name servers (found in outputs)
4. DNS propagation typically completes within 24-48 hours

## 🔄 Deployment & Operations

### Terraform Cloud Workspace
All deployments are managed through Terraform Cloud:
- **Plans**: Automatically triggered on pull requests
- **Applies**: Automatically executed on main branch merges
- **State**: Securely stored and managed in Terraform Cloud
- **Variables**: Configured in workspace settings

### Environment Management
- Production environment uses the root configuration
- Development/staging environments available in `environments/` (future expansion)
- Environment-specific variables managed through Terraform Cloud workspaces

### Monitoring Deployment Status
Monitor deployments through:
- GitHub Actions workflow status
- Terraform Cloud run history
- AWS CloudFormation events (for infrastructure changes)

## 📊 Infrastructure Outputs

After deployment, these outputs are available in Terraform Cloud:

| Output | Description |
|--------|-------------|
| `website_url` | Complete website URL (CloudFront or custom domain) |
| `cloudfront_distribution_id` | CloudFront distribution ID for cache management |
| `website_bucket_name` | S3 bucket name for content uploads |
| `route53_name_servers` | DNS name servers (custom domain only) |

## 🔐 Security & Best Practices

### Access Controls
- S3 bucket uses Origin Access Control (OAC) with CloudFront
- IAM policies follow least privilege principles
- All resources use encryption at rest

### HTTPS Enforcement
- CloudFront automatically redirects HTTP to HTTPS
- Modern TLS protocols and cipher suites only
- HSTS headers enabled for enhanced security

### Credentials Management
- AWS credentials stored as encrypted environment variables in Terraform Cloud
- No sensitive data committed to version control
- `.tfvars` files excluded via `.gitignore`

## 🐛 Troubleshooting

### Common Issues

**Deployment Failures:**
- Check Terraform Cloud run logs for detailed error messages
- Verify AWS permissions in workspace environment variables
- Ensure S3 bucket names are globally unique

**Domain Issues:**
- Verify name servers are correctly configured at domain registrar
- Check Route53 hosted zone records match expected configuration
- Allow 24-48 hours for DNS propagation

**CloudFront Cache Issues:**
- Use distribution ID from outputs to create cache invalidations
- Content updates may take up to 24 hours to propagate globally
- Create invalidation for `/*` to clear all cached content

### Useful Operations

```bash
# View deployment status
# (Check Terraform Cloud workspace runs)

# Create CloudFront invalidation
aws cloudfront create-invalidation \
  --distribution-id <DISTRIBUTION_ID> \
  --paths "/*"

# Check domain propagation
dig <your-domain> NS
nslookup <your-domain>
```

## 🔧 Configuration Management

### Variable Updates
Modify infrastructure by updating variables in Terraform Cloud workspace:
1. Navigate to workspace settings
2. Update environment variables or Terraform variables
3. Queue new plan to preview changes
4. Apply changes through Terraform Cloud interface

### Adding Features
- Edit `.tf` files in this directory
- Commit changes to trigger automatic planning
- Review plan output in pull request
- Merge to main branch for automatic deployment

## 📚 References

- [Terraform Cloud Workspace](https://app.terraform.io) - Deployment management
- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [Route53 DNS Management](https://docs.aws.amazon.com/route53/) 
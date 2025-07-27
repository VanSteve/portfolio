# Portfolio Infrastructure - Terraform Cloud Setup

This directory contains the Terraform configuration for the portfolio website infrastructure, designed to work with Terraform Cloud for remote state management and automated deployments.

## 🏗️ Architecture Overview

The infrastructure includes:
- **S3 Bucket**: Static website hosting with public read access
- **CloudFront Distribution**: Global CDN with HTTPS redirect
- **ACM Certificate**: SSL/TLS certificate for custom domains (optional)
- **Route53**: DNS management for custom domains (optional)

## 🚀 Terraform Cloud Setup

### Step 5: Commit and Push Terraform Configuration

(Steps 1-4 are already completed)

**Before testing connectivity, you must commit the Terraform files to GitHub:**

1. **Commit the Terraform configuration files** to your repository:
   ```bash
   git add terraform/
   git commit -m "Add Terraform Cloud configuration for portfolio infrastructure"
   git push origin main
   ```

2. **Wait for the push to complete** - Terraform Cloud will automatically detect the new files

### Step 6: Test Connectivity

1. In Terraform Cloud workspace, click **"Start new plan"**
2. Add an optional description like "Initial connectivity test"
3. **Review the plan output** to verify:
   - AWS credentials are working
   - All required resources will be created (S3, CloudFront, etc.)
   - No permission errors
4. If successful, apply the changes by clicking **"Confirm & Apply"**
5. **Monitor the apply process** and verify resources are created in AWS console

## 📁 File Structure

```
terraform/
├── main.tf                 # Main infrastructure resources
├── variables.tf           # Input variable definitions
├── outputs.tf            # Output value definitions
├── terraform.tf          # Provider and version constraints
├── terraform.tfvars.example  # Example variable values
└── README.md             # This documentation
```

## 🔧 Local Development

### Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads.html) >= 1.0
- AWS CLI configured
- Terraform Cloud CLI access

### Setup

1. **Login to Terraform Cloud**:
   ```bash
   terraform login
   ```

2. **Initialize Terraform**:
   ```bash
   cd terraform/
   terraform init
   ```

3. **Plan Infrastructure**:
   ```bash
   terraform plan
   ```

4. **Apply Changes** (if needed locally):
   ```bash
   terraform apply
   ```

## 🌍 Domain Configuration

### Without Custom Domain
- Website will be accessible via CloudFront domain
- Example: `https://d123456789abcdef.cloudfront.net`

### With Custom Domain
1. Set `domain_name` variable to your domain (e.g., `fitzs.io`)
2. After deployment, update your domain registrar's name servers to use Route53
3. Certificate validation will be automatic via DNS

## 🔐 Security Best Practices

- AWS credentials are stored as sensitive environment variables
- S3 bucket uses least privilege access policies
- CloudFront enforces HTTPS redirects
- Certificate uses modern TLS protocols

## 📊 Outputs

After successful deployment, the following outputs will be available:

- `website_url`: Complete website URL
- `cloudfront_distribution_id`: CloudFront distribution ID
- `website_bucket_name`: S3 bucket name
- `route53_name_servers`: DNS name servers (if using custom domain)

## 🔄 CI/CD Integration

The Terraform Cloud workspace integrates with GitHub Actions for:
- Automated plans on pull requests
- Automated applies on main branch merges
- Infrastructure drift detection

## 🐛 Troubleshooting

### Common Issues

1. **Bucket name already exists**:
   - Change `website_bucket_name` to a unique value
   - S3 bucket names must be globally unique

2. **AWS credentials error**:
   - Verify AWS credentials in Terraform Cloud environment variables
   - Ensure IAM user has necessary permissions

3. **Domain validation timeout**:
   - Check that name servers are correctly configured
   - DNS propagation can take up to 48 hours

### Useful Commands

```bash
# View current state
terraform show

# Refresh state
terraform refresh

# Validate configuration
terraform validate

# Format code
terraform fmt
```

## 📚 Additional Resources

- [Terraform Cloud Documentation](https://www.terraform.io/cloud-docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/) 
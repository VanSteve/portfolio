# GitHub Repository Secrets Configuration

This document outlines all the required GitHub repository secrets needed for the CI/CD pipeline to function properly.

## 🔐 Required Secrets

### AWS Credentials

#### `AWS_ACCESS_KEY_ID`
- **Description**: AWS access key ID for deploying to S3 and managing CloudFront
- **Scope**: Repository secret
- **Used by**: 
  - `deploy-staging.yml`
  - `deploy-prod.yml`
- **How to obtain**: 
  1. Create an IAM user in AWS Console
  2. Attach the policy below (or use existing user)
  3. Generate access keys
- **Required permissions**:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:CreateBucket",
          "s3:PutBucketLifecycleConfiguration"
        ],
        "Resource": [
          "arn:aws:s3:::portfolio-*",
          "arn:aws:s3:::portfolio-*/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetDistribution",
          "cloudfront:ListDistributions"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListAllMyBuckets"
        ],
        "Resource": "*"
      }
    ]
  }
  ```

#### `AWS_SECRET_ACCESS_KEY`
- **Description**: AWS secret access key corresponding to the access key ID
- **Scope**: Repository secret
- **Used by**: 
  - `deploy-staging.yml`
  - `deploy-prod.yml`
- **How to obtain**: Generated together with `AWS_ACCESS_KEY_ID`

## 📝 Optional Secrets

### Terraform Cloud Integration (Not Currently Used)

Since Terraform Cloud handles infrastructure deployment via VCS integration, GitHub Actions doesn't need direct access to Terraform Cloud. Infrastructure changes are automatically deployed when Terraform files are merged to the `main` branch.

If you need GitHub Actions to interact with Terraform Cloud in the future:

#### `TERRAFORM_CLOUD_TOKEN`
- **Description**: API token for Terraform Cloud integration  
- **Scope**: Repository secret
- **How to obtain**:
  1. Log in to [Terraform Cloud](https://app.terraform.io/)
  2. Go to User Settings → Tokens
  3. Generate a new API token
  4. Copy the token value

## 🏗️ Setting Up GitHub Environments

Before setting up secrets, you need to create the required environments in your GitHub repository:

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Environments** 
3. Create the following environments:
   - `staging` (for staging deployments)
   - `production` (for production deployments)
4. Optionally add protection rules:
   - **Production**: Require manual approval before deployment
   - **Production**: Restrict to `main` branch only

## 🔧 Setting Up Secrets

### Via GitHub Web Interface

1. Navigate to your repository on GitHub
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Enter the secret name (exactly as shown above)
5. Paste the secret value
6. Click **Add secret**

### Via GitHub CLI

```bash
# Set AWS credentials
gh secret set AWS_ACCESS_KEY_ID --body "your-access-key-id"
gh secret set AWS_SECRET_ACCESS_KEY --body "your-secret-access-key"

# Terraform Cloud token (only if needed for future integrations)
# gh secret set TERRAFORM_CLOUD_TOKEN --body "your-terraform-cloud-token"
```

## 🛡️ Security Best Practices

### AWS IAM User Setup

1. **Create dedicated IAM user**: Don't use root credentials
2. **Principle of least privilege**: Only grant necessary permissions
3. **Enable MFA**: For the IAM user if possible
4. **Regular rotation**: Rotate access keys periodically
5. **Monitor usage**: Set up CloudTrail to monitor API usage

### Terraform Cloud Token

1. **Team-specific tokens**: Use team tokens if working in a team
2. **Scope limitation**: Limit token access to specific workspaces
3. **Regular rotation**: Rotate tokens periodically
4. **Monitor usage**: Check Terraform Cloud audit logs

## 🧪 Testing Secret Configuration

### Test AWS Credentials

```bash
# Test AWS CLI access (run locally with same credentials)
aws s3 ls
aws cloudfront list-distributions
```

### Test Terraform Cloud Token

```bash
# Test Terraform Cloud API access
curl -H "Authorization: Bearer $TERRAFORM_CLOUD_TOKEN" \
     https://app.terraform.io/api/v2/organizations/vansteve-portfolio
```

## 🚨 Troubleshooting

### Common Issues

#### AWS Permission Denied
- **Symptom**: `AccessDenied` errors in deployment logs
- **Solution**: Verify IAM user has all required permissions
- **Check**: Ensure bucket names match the policy patterns

#### Terraform Cloud Authentication Failed
- **Symptom**: `401 Unauthorized` errors in infrastructure workflow
- **Solution**: Verify token is valid and has organization access
- **Check**: Ensure workspaces exist with correct names

#### Workflow Not Triggered
- **Symptom**: Workflows don't run or fail immediately
- **Solution**: Check secret names match exactly (case-sensitive)
- **Check**: Verify secrets are set at repository level, not environment level

### Debug Commands

Add these steps to workflows for debugging (remove after fixing):

```yaml
- name: Debug AWS Configuration
  run: |
    aws sts get-caller-identity
    aws s3 ls

- name: Debug Terraform Cloud
  run: |
    curl -H "Authorization: Bearer $TF_API_TOKEN" \
         https://app.terraform.io/api/v2/organizations/vansteve-portfolio
```

## 📋 Secret Checklist

Before pushing changes, ensure:

- [ ] `AWS_ACCESS_KEY_ID` is set and valid
- [ ] `AWS_SECRET_ACCESS_KEY` is set and valid
- [ ] `TERRAFORM_CLOUD_TOKEN` is set (only if using GitHub Actions for Terraform)
- [ ] AWS IAM user has required S3 and CloudFront permissions
- [ ] Terraform Cloud token has access to organization and workspaces
- [ ] All secret names match exactly (case-sensitive)
- [ ] Secrets are set at repository level, not environment level

## 🔄 Secret Rotation Schedule

- **AWS Credentials**: Every 90 days
- **Terraform Cloud Token**: Every 180 days (if used)
- **Review access**: Monthly

## 📞 Support

If you encounter issues with secret configuration:

1. Check this documentation first
2. Verify AWS IAM permissions in AWS Console
3. Verify Terraform Cloud access in Terraform Cloud UI
4. Check GitHub Actions logs for specific error messages
5. Test credentials locally using the debug commands above
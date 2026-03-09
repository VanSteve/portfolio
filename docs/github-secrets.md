# GitHub Repository Secrets & AWS OIDC Configuration

This document covers the authentication setup between GitHub Actions and AWS for the CI/CD pipeline. The pipeline uses **OIDC (OpenID Connect) federation** rather than long-lived access keys -- this is the AWS-recommended approach for GitHub Actions.

## How It Works

Instead of storing static AWS credentials, GitHub Actions requests a short-lived OIDC token from GitHub's identity provider and exchanges it with AWS STS for temporary session credentials. No secrets to rotate, no keys to leak.

```
GitHub Actions Runner
  │
  ├─ Requests OIDC token from GitHub's IdP
  │    (token.actions.githubusercontent.com)
  │
  ├─ Sends token to AWS STS (AssumeRoleWithWebIdentity)
  │
  └─ Receives temporary credentials scoped to IAM role
       (valid ~1 hour, auto-expire)
```

## One-Time AWS Setup

### Step 1: Create the OIDC Identity Provider

1. Open the **AWS Console** > **IAM** > **Identity providers**
2. Click **Add provider**
3. Configure:
   - **Provider type**: OpenID Connect
   - **Provider URL**: `https://token.actions.githubusercontent.com`
   - **Audience**: `sts.amazonaws.com`
4. Click **Add provider**

> You only need one OIDC provider per AWS account, even if multiple repos use it.

### Step 2: Create the IAM Role

1. Go to **IAM** > **Roles** > **Create role**
2. Select **Web identity** as the trusted entity type
3. Choose:
   - **Identity provider**: `token.actions.githubusercontent.com`
   - **Audience**: `sts.amazonaws.com`
4. Click **Next** and attach the permissions policy below
5. Name the role (e.g., `GitHubActionsDeployRole`)
6. After creation, edit the role's **Trust policy** to scope it to your repository:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<YOUR_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:VanSteve/portfolio:*"
        }
      }
    }
  ]
}
```

> Replace `<YOUR_ACCOUNT_ID>` with your 12-digit AWS account ID.
>
> The `sub` condition restricts this role to only be assumable by workflows running in the `VanSteve/portfolio` repo. You can further restrict to specific branches or environments (e.g., `repo:VanSteve/portfolio:ref:refs/heads/main`).

### Step 3: Permissions Policy

Attach this policy to the role (same permissions previously used by the IAM user):

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

## Required GitHub Secret

Only **one** repository secret is needed for AWS authentication:

### `AWS_ROLE_ARN`
- **Description**: ARN of the IAM role GitHub Actions assumes via OIDC
- **Format**: `arn:aws:iam::<ACCOUNT_ID>:role/GitHubActionsDeployRole`
- **Used by**:
  - `deploy-staging.yml`
  - `deploy-prod.yml`

#### Setting the secret

**Via GitHub Web Interface:**
1. Navigate to your repository on GitHub
2. Go to **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret**
4. Name: `AWS_ROLE_ARN`
5. Value: the full ARN of your IAM role
6. Click **Add secret**

**Via GitHub CLI:**
```bash
gh secret set AWS_ROLE_ARN --body "arn:aws:iam::<ACCOUNT_ID>:role/GitHubActionsDeployRole"
```

## Optional Secrets

### Terraform Cloud Integration (Not Currently Used)

Terraform Cloud handles infrastructure deployment via VCS integration. GitHub Actions does not need direct access to Terraform Cloud. If this changes in the future:

#### `TERRAFORM_CLOUD_TOKEN`
- **Description**: API token for Terraform Cloud integration
- **How to obtain**:
  1. Log in to [Terraform Cloud](https://app.terraform.io/)
  2. Go to User Settings > Tokens
  3. Generate a new API token

## GitHub Environments

Create these environments in **Settings** > **Environments**:

- **`staging`** -- for staging deployments
- **`production`** -- for production deployments
  - Recommended: require manual approval before deployment
  - Recommended: restrict to `main` branch only

## How It Appears in Workflows

The deploy workflows use the OIDC flow via `aws-actions/configure-aws-credentials@v4`:

```yaml
permissions:
  id-token: write    # Required for OIDC token request
  contents: read

steps:
  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
      aws-region: us-west-2
```

The `id-token: write` permission is required for the runner to request the OIDC token from GitHub. The action handles the STS `AssumeRoleWithWebIdentity` call automatically.

## Troubleshooting

### "Not authorized to perform sts:AssumeRoleWithWebIdentity"
- **Cause**: The IAM role trust policy doesn't match the requesting repo/branch
- **Fix**: Verify the `sub` condition in the trust policy matches `repo:VanSteve/portfolio:*`
- **Check**: Ensure the OIDC provider thumbprint is up to date (AWS manages this automatically for `token.actions.githubusercontent.com`)

### "No credentials found" or "Could not assume role"
- **Cause**: Missing `permissions: id-token: write` in the workflow job
- **Fix**: Ensure the deploy job has the `permissions` block

### "AccessDenied" on S3 or CloudFront operations
- **Cause**: The IAM role's permissions policy doesn't cover the required actions
- **Fix**: Verify the permissions policy attached to the role matches the one documented above
- **Check**: Ensure S3 bucket names match the `portfolio-*` pattern in the policy

### Workflow not triggered
- **Cause**: Secret name mismatch (case-sensitive)
- **Fix**: Verify `AWS_ROLE_ARN` is set exactly as named at the repository level

### Debug step

Add temporarily to a workflow to verify the assumed identity:

```yaml
- name: Debug AWS identity
  run: aws sts get-caller-identity
```

The output should show the role ARN and a session name like `GitHubActions-...`.

## Security Advantages over Access Keys

| | Access Keys | OIDC Federation |
|---|---|---|
| Credential lifetime | Permanent until rotated | ~1 hour, auto-expires |
| Rotation needed | Every 90 days | Never (no static credentials) |
| Leak risk | Key in secret store could be exfiltrated | No key exists to leak |
| Scope | IAM user can be used from anywhere | Scoped to specific repo via trust policy |
| Auditability | CloudTrail shows IAM user | CloudTrail shows role + GitHub session |

## Checklist

- [ ] OIDC Identity Provider created in AWS IAM
- [ ] IAM Role created with trust policy scoped to `VanSteve/portfolio`
- [ ] Permissions policy attached to the role
- [ ] `AWS_ROLE_ARN` secret set in GitHub repository
- [ ] `staging` and `production` environments created in GitHub
- [ ] Test deployment triggers successfully from a PR merge

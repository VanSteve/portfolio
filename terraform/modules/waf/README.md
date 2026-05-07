# WAF Module

Deploys an AWS WAFv2 Web ACL configured for use with CloudFront. Provides edge-level protection against common web exploits, known bad inputs, and request flooding.

> **Provider requirement**: WAF Web ACLs associated with CloudFront must reside in `us-east-1`. When calling this module, pass the `us-east-1` provider alias as the module's default provider:
> ```hcl
> module "waf" {
>   source    = "../../modules/waf"
>   providers = { aws = aws.us_east_1 }
>   ...
> }
> ```

## Rules

Rules are evaluated in priority order (lowest number first):

| Priority | Rule | Action |
|----------|------|--------|
| 1 | Rate limiting (per IP) | Block |
| 5 | Geographic blocking (optional) | Block |
| 10 | AWS Managed — Core Rule Set (CRS) | Block matching |
| 20 | AWS Managed — Known Bad Inputs | Block matching |
| — | Default | Allow |

**Core Rule Set** protects against OWASP Top 10 threats including SQL injection, cross-site scripting, and path traversal.

**Known Bad Inputs** blocks requests containing log4j exploit strings, SSRF payloads, and other known malicious patterns.

**Rate limiting** blocks any single IP that exceeds `var.rate_limit` requests within a 5-minute window.

## Usage

```hcl
module "waf" {
  source = "../../modules/waf"

  providers = {
    aws = aws.us_east_1
  }

  name       = "portfolio-waf-prod"
  rate_limit = 1000

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

module "cloudfront" {
  source = "../../modules/cloudfront"
  ...
  web_acl_id = module.waf.web_acl_arn
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name of the WAF Web ACL | `string` | — | yes |
| `rate_limit` | Max requests per IP per 5-minute window before blocking | `number` | `2000` | no |
| `enable_geo_block` | Enable geographic blocking | `bool` | `false` | no |
| `blocked_countries` | ISO 3166-1 alpha-2 country codes to block | `list(string)` | `[]` | no |
| `tags` | Tags to apply to WAF resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `web_acl_arn` | ARN of the WAF Web ACL — pass to CloudFront module as `web_acl_id` |
| `web_acl_id` | ID of the WAF Web ACL |
| `web_acl_name` | Name of the WAF Web ACL |
| `web_acl_capacity` | Capacity units consumed (max 1500 for CloudFront scope) |

## Removing WAF

To disable WAF for an environment without removing module code, set `enable_waf = false` in the environment's `terraform.tfvars` and run `terraform apply`. The Web ACL and its association with CloudFront will be destroyed cleanly with no downtime.

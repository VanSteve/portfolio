# WAF Web ACL Module

resource "aws_wafv2_web_acl" "main" {
  name        = var.name
  description = "WAF Web ACL for ${var.name}"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Priority 1: Rate limiting — evaluated first to shed abusive IPs before
  # the more expensive managed rule groups run against their requests.
  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-RateLimit"
      sampled_requests_enabled   = true
    }
  }

  # Priority 5: Optional geographic blocking
  dynamic "rule" {
    for_each = var.enable_geo_block && length(var.blocked_countries) > 0 ? [1] : []
    content {
      name     = "GeoBlockRule"
      priority = 5

      action {
        block {}
      }

      statement {
        geo_match_statement {
          country_codes = var.blocked_countries
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-GeoBlock"
        sampled_requests_enabled   = true
      }
    }
  }

  # Priority 10: AWS Managed Core Rule Set — protects against OWASP Top 10
  # (SQLi, XSS, path traversal, etc.)
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Priority 20: AWS Managed Known Bad Inputs — blocks log4j exploits,
  # SSRF attempts, and other known malicious payload patterns.
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = true
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !var.enable_geo_block || length(var.blocked_countries) > 0
      error_message = "enable_geo_block is true but blocked_countries is empty — no countries would be blocked. Either add country codes or set enable_geo_block = false."
    }
  }
}

# WAF Module - Variables

variable "name" {
  description = "Name of the WAF Web ACL"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{0,127}$", var.name))
    error_message = "WAF Web ACL name must be 1-128 characters, start with an alphanumeric character, and contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "rate_limit" {
  description = "Maximum requests from a single IP in a 5-minute window before blocking"
  type        = number
  default     = 2000

  validation {
    condition     = var.rate_limit >= 100 && var.rate_limit <= 20000000
    error_message = "Rate limit must be between 100 and 20,000,000."
  }
}

variable "enable_geo_block" {
  description = "Enable geographic blocking rules"
  type        = bool
  default     = false
}

variable "blocked_countries" {
  description = "ISO 3166-1 alpha-2 country codes to block (e.g. [\"CN\", \"RU\"]). Only used when enable_geo_block is true."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to WAF resources"
  type        = map(string)
  default     = {}
}

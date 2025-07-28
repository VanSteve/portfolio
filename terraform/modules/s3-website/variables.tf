# S3 Website Hosting Module - Variables
# Input variables for the S3 website hosting module

variable "bucket_name" {
  description = "Name of the S3 bucket for website hosting"
  type        = string
  
  validation {
    condition = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name)) && length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "S3 bucket name must be 3-63 characters, lowercase letters, numbers, periods, and hyphens only."
  }
}

variable "index_document" {
  description = "Index document for the website"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for the website"
  type        = string
  default     = "404.html"
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "S3 bucket lifecycle configuration"
  type = object({
    enabled                        = bool
    noncurrent_version_expiration  = number
    delete_markers_expiration      = bool
  })
  default = {
    enabled                        = true
    noncurrent_version_expiration  = 30
    delete_markers_expiration      = true
  }
}

variable "tags" {
  description = "Additional tags for the S3 bucket"
  type        = map(string)
  default     = {}
} 
variable "iam_access_key" {
  description = "IAM access key"

  type      = string
  sensitive = true
  default   = ""
}
variable "iam_secret_key" {
  description = "IAM secret key"

  type      = string
  sensitive = true
  default   = ""
}

variable "environment" {
  type    = string
  default = "develop"
}
variable "project" {
  type    = string
  default = "sbis"
}

variable "default_tags" {
  description = "Default tags"
  type        = map(string)
  default = {
    "module_name" = "s3"
  }
}

variable "s3_mgmt" {
  description = "Config for S3 buckets"
  type = object({
    buckets = map(object({
      storage_class = optional(string)
      acl           = optional(string)
      policy        = optional(string)
      policy_format = optional(string)
      tags          = optional(map(string))
      versioning    = optional(bool)
      logging = object({
        enable        = bool
        target_bucket = optional(string)
        target_prefix = optional(string)
        agency        = optional(string)
      })
      quota = optional(number)
      website = optional(object({
        enable                   = optional(bool)
        index_document           = optional(string)
        error_document           = optional(string)
        redirect_all_requests_to = optional(string)
        routing_rules            = optional(string)
      }))
      cors_rule = optional(map(object({
        allowed_origins = optional(list(string))
        allowed_methods = optional(list(string))
        allowed_headers = optional(list(string))
        expose_headers  = optional(list(string))
        max_age_seconds = optional(number)
      })))
      lifecycle_rule = optional(map(object({
        name    = optional(string) # Название правила
        prefix  = optional(string)
        enabled = optional(bool)
        expiration = optional(object({
          days = optional(number)
        }))
        transition = optional(list(object({
          days          = optional(number)
          storage_class = optional(string)
        })))
        noncurrent_version_expiration = optional(object({
          days = optional(number)
        }))
        noncurrent_version_transition = optional(list(object({
          days          = optional(number)
          storage_class = optional(string)
        })))
        abort_incomplete_multipart_upload = optional(object({
          days = optional(number)
        }))
      })))
      force_destroy         = optional(bool)
      region                = optional(string)
      parallel_fs           = optional(bool)
      multi_az              = optional(bool)
      encryption            = optional(bool)
      sse_algorithm         = optional(string)
      kms_key_id            = optional(string)
      kms_key_project_id    = optional(string)
      enterprise_project_id = optional(string)
      user_domain_names     = optional(list(string))
    }))
  })
  validation {
    condition = alltrue([
      for bucket_name, bucket in var.s3_mgmt.buckets : (
        bucket.logging.enable == false ||                                                                        # Если enable == false, target_bucket и agency не обязательны
        (bucket.logging.enable == true && bucket.logging.target_bucket != null && bucket.logging.agency != null) # Проверяем, если enable == true
      )
    ])
    error_message = "When logging is enabled, both 'target_bucket' and 'agency' must be specified."
  }
}
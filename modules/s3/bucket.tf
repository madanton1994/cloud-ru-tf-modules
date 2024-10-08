resource "huaweicloud_obs_bucket" "s3_bucket" {
  for_each      = { for s3 in local.buckets_local : "${s3.bucket}" => s3 if s3 != [] }
  bucket        = each.value.bucket
  storage_class = each.value.storage_class
  acl           = each.value.acl
  policy        = each.value.policy
  policy_format = each.value.policy_format
  versioning    = each.value.versioning
  dynamic "logging" {
    # for_each = each.value.bucket_logging.enable == true ? tomap(each.value.bucket_logging.config) : {}
    # for_each = { for logs_key, logs_config in each.value.logging_parced : "${s3.bucket_name}.${logs.target_bucket}" => logs if each.value.logging_parced != {} }
    for_each = length(each.value.logging_parced) > 0 ? { for idx, config in each.value.logging_parced : idx => config } : {}
    # iterator = "logsconf"
    iterator = logsconf
    content {
      target_bucket = lookup(logsconf.value, "target_bucket", null)
      target_prefix = "${lookup(logsconf.value, "target_prefix", "")}/${each.value.bucket}/"
      agency        = lookup(logsconf.value, "agency", null)
    }
  }

  dynamic "website" {
    for_each = length(each.value.website_parced) > 0 ? { for idx, config in each.value.website_parced : idx => config } : {}
    content {
      index_document           = lookup(each.value.website_parced[0], "index_document", null)
      error_document           = lookup(each.value.website_parced[0], "error_document", null)
      redirect_all_requests_to = lookup(each.value.website_parced[0], "redirect_all_requests_to", null)
      routing_rules            = lookup(each.value.website_parced[0], "routing_rules", null)
    }
  }

  dynamic "cors_rule" {
    for_each = each.value.cors_rule_parced
    content {
      allowed_origins = cors_rule.value.allowed_origins
      allowed_methods = cors_rule.value.allowed_methods
      allowed_headers = cors_rule.value.allowed_headers
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }


  # Dynamic block for lifecycle rules
  dynamic "lifecycle_rule" {
    for_each = length(each.value.lifecycle_rule_parced) > 0 ? { for idx, config in each.value.lifecycle_rule_parced : idx => config } : {}
    iterator = lifeconf
    content {
      name    = lookup(lifeconf.value, "name", null)
      prefix  = lookup(lifeconf.value, "prefix", null)
      enabled = lookup(lifeconf.value, "enabled", false)

      # expiration block
      dynamic "expiration" {
        for_each = lookup(lifeconf.value, "expiration", [])
        content {
          days = lookup(expiration.value, "days", null)
        }
      }

      # transition block
      dynamic "transition" {
        for_each = lookup(lifeconf.value, "transition", [])
        content {
          days          = lookup(transition.value, "days", null)
          storage_class = lookup(transition.value, "storage_class", null)
        }
      }

      # noncurrent_version_expiration block
      dynamic "noncurrent_version_expiration" {
        for_each = lookup(lifeconf.value, "noncurrent_version_expiration", [])
        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      # noncurrent_version_transition block
      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifeconf.value, "noncurrent_version_transition", [])
        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = lookup(noncurrent_version_transition.value, "storage_class", null)
        }
      }

      # abort_incomplete_multipart_upload block
      dynamic "abort_incomplete_multipart_upload" {
        for_each = lookup(lifeconf.value, "abort_incomplete_multipart_upload", [])
        content {
          days = lookup(abort_incomplete_multipart_upload.value, "days", null)
        }
      }
    }
  }



  quota                 = each.value.quota
  force_destroy         = each.value.force_destroy
  region                = each.value.region
  parallel_fs           = each.value.parallel_fs
  multi_az              = each.value.multi_az
  encryption            = each.value.encryption
  sse_algorithm         = each.value.sse_algorithm
  kms_key_id            = each.value.kms_key_id
  kms_key_project_id    = each.value.kms_key_project_id
  enterprise_project_id = each.value.enterprise_project_id
  # user_domain_names     = {}


  tags = each.value.tags
}
locals {
  buckets_local = distinct(flatten([
    for bucket_name, bucket_config in var.s3_mgmt.buckets : {
      bucket        = bucket_name
      storage_class = bucket_config.storage_class
      acl           = bucket_config.acl
      policy        = bucket_config.policy
      policy_format = bucket_config.policy_format
      versioning    = bucket_config.versioning

      logging_parced = bucket_config.logging != null && bucket_config.logging.enable == true ? [
        {
          target_bucket = bucket_config.logging.target_bucket
          target_prefix = bucket_config.logging.target_prefix
          agency        = bucket_config.logging.agency
        }
      ] : []

      website_parced = bucket_config.website != null && try(bucket_config.website.enable, false) == true ? [
        {
          index_document           = lookup(bucket_config.website, "index_document", null)
          error_document           = lookup(bucket_config.website, "error_document", null)
          redirect_all_requests_to = lookup(bucket_config.website, "redirect_all_requests_to", null)
          routing_rules = bucket_config.website.routing_rules != null ? bucket_config.website.routing_rules : null
        }
      ] : []

      cors_rule_parced = bucket_config.cors_rule != null ? distinct([
        for cors_rule_name, cors_rule in bucket_config.cors_rule : {
          allowed_origins = cors_rule.allowed_origins
          allowed_methods = cors_rule.allowed_methods
          allowed_headers = cors_rule.allowed_headers
          expose_headers  = cors_rule.expose_headers
          max_age_seconds = cors_rule.max_age_seconds
        }
      ]) : []

      lifecycle_rule_parced = bucket_config.lifecycle_rule != null ? [
        for rule_name, rule in bucket_config.lifecycle_rule : {
          name    = lookup(rule, "name", null)
          prefix  = lookup(rule, "prefix", null)
          enabled = lookup(rule, "enabled", false)

          expiration = lookup(rule, "expiration", null) != null ? [{
            days = lookup(rule.expiration, "days", null)
          }] : []

          transition = lookup(rule, "transition", null) != null ? [
            for trans in rule.transition : {
              days          = lookup(trans, "days", null)
              storage_class = lookup(trans, "storage_class", null)
            }
          ] : []

          noncurrent_version_expiration = lookup(rule, "noncurrent_version_expiration", null) != null ? [{
            days = lookup(rule.noncurrent_version_expiration, "days", null)
          }] : []

          noncurrent_version_transition = lookup(rule, "noncurrent_version_transition", null) != null ? [
            for trans in rule.noncurrent_version_transition : {
              days          = lookup(trans, "days", null)
              storage_class = lookup(trans, "storage_class", null)
            }
          ] : []

          abort_incomplete_multipart_upload = lookup(rule, "abort_incomplete_multipart_upload", null) != null ? [{
            days = lookup(rule.abort_incomplete_multipart_upload, "days", null)
          }] : []
        }
      ] : []

      quota                 = bucket_config.quota
      force_destroy         = bucket_config.force_destroy
      region                = bucket_config.region
      parallel_fs           = bucket_config.parallel_fs
      multi_az              = bucket_config.multi_az
      encryption            = bucket_config.encryption
      sse_algorithm         = bucket_config.sse_algorithm
      kms_key_id            = bucket_config.kms_key_id
      kms_key_project_id    = bucket_config.kms_key_project_id
      enterprise_project_id = bucket_config.enterprise_project_id
      tags                  = merge(var.default_tags, coalesce(bucket_config.tags, var.default_tags))
    }
  ]))

}

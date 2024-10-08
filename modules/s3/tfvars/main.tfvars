s3_mgmt = {
  buckets = {
    prod-buckets-logs-test = {
      storage_class = "STANDARD"
      acl           = "log-delivery-write"
      versioning    = false
      multi_az      = true
      logging = {
        enable = false
      }
      tags = {
        "target"             = "logging-buckets"
        "resource-type"      = "obs"
        "usage-service-name" = "obs"
        "platform-usage"     = "huaweicloud"
        "service-tenant"     = "advanced"
      }
    }
    module-test-1-claims = {
      storage_class = "STANDARD"
      acl           = "private"
      # policy        = <<EOF
      #           {
      #             "key1": "value1",
      #             "key2": "value2",
      #             "key3": {
      #               "nested_key": "nested_value"
      #             }
      #           }
      #           EOF
      policy_format = "obs"
      versioning    = true
      logging = {
        enable        = false
        target_bucket = "prod-buckets-logs-test"
        agency        = "s3_prod_logging_agency"
        target_prefix = "logs"
      }
      quota = 0
      website = {
        enable                   = true
        index_document           = "index.html"
        error_document           = "error.html"
        redirect_all_requests_to = null

        # routing_rules как строка JSON через EOF
        routing_rules = <<EOF
[
  {
    "Condition": {
      "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
      "ReplaceKeyPrefixWith": "documents/"
    }
  },
  {
    "Condition": {
      "HttpErrorCodeReturnedEquals": "404"
    },
    "Redirect": {
      "ReplaceKeyWith": "404.html"
    }
  }
]
EOF
      }

      cors_rule = {
        cors_website_2 = {
          allowed_origins = ["https://obs-website-test.hashicorp.com"]
          allowed_methods = ["GET", "POST"]
          allowed_headers = ["*"]
          expose_headers  = ["ETag"]
          max_age_seconds = 3000
        }
      }

      lifecycle_rule = {
        log = {
          name    = "log"
          prefix  = "log/"
          enabled = true
          expiration = {
            days = 365
          }
          transition = [
            {
              days          = 60
              storage_class = "WARM"
            },
            {
              days          = 180
              storage_class = "COLD"
            }
          ]
          abort_incomplete_multipart_upload = {
            days = 360
          }
        }
        tmp = {
          name    = "tmp"
          enabled = true
          noncurrent_version_expiration = {
            days = 180
          }
          noncurrent_version_transition = [
            {
              days          = 30
              storage_class = "WARM"
            },
            {
              days          = 60
              storage_class = "COLD"
            }
          ]
        }
      }
      force_destroy = false
      region        = "ru-moscow-1"
      parallel_fs   = false
      multi_az      = true
      encryption    = true
      sse_algorithm = "kms" # AES256 - Server-side encryption with keys managed by OBS are used to encrypt your objects.
      # kms_key_id            = "2a42ac29-eea4-406b-a44a-fbcc02c82acc"    # This field is used only when sse_algorithm value is kms
      # kms_key_project_id    = "550a06e2-f817-446f-ab40-234a7743de0b"    # This field is valid only when kms_key_id is specified
      enterprise_project_id = ""
      user_domain_names     = []
      tags = {
        "resource-type"      = "obs"
        "platform-usage"     = "k8s"
        "service-tenant"     = "advanced"
      }

    }
  }
}
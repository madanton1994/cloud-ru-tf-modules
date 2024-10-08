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
}

variable "kms_keys" {
  description = "List of KMS keys"
  type = map(object({
    region                = optional(string)
    key_description       = optional(string)
    key_algorithm         = optional(string)
    pending_days          = optional(string)
    is_enabled            = optional(bool)
    rotation_enabled      = optional(bool)
    rotation_interval     = optional(number)
    enterprise_project_id = optional(string)
    tags                  = optional(map(string))
    origin                = optional(string)
    key_usage             = optional(string)
    keystore_id           = optional(string)
    key_pairs = optional(map(object({
      scope           = optional(string)
      encryption_type = optional(string)
      kms_key_name    = optional(string)
      description     = optional(string)
      public_key      = optional(string)
      private_key     = optional(string)
      key_file        = optional(string)
    })))
    }
  ))
}


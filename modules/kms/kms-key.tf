resource "huaweicloud_kms_key" "kms_key" {
  for_each              = { for entry in local.kms_key_local : "${var.project}.${var.environment}.${entry.name}" => entry }
  region                = each.value.region
  key_alias             = each.value.key_alias
  key_description       = each.value.key_description
  key_algorithm         = each.value.key_algorithm
  pending_days          = each.value.pending_days
  is_enabled            = each.value.is_enabled
  rotation_enabled      = each.value.rotation_enabled
  rotation_interval     = each.value.rotation_interval
  enterprise_project_id = each.value.enterprise_project_id
  tags                  = each.value.tags
  origin                = each.value.origin
  key_usage             = each.value.key_usage
  keystore_id           = each.value.keystore_id
}


resource "huaweicloud_kps_keypair" "key_pairs" {
  depends_on      = [huaweicloud_kms_key.kms_key]
  for_each        = { for entry in local.key_pair_local : "${var.project}.${var.environment}.${entry.name}" => entry }
  region          = each.value.region
  name            = each.value.name
  scope           = each.value.scope
  encryption_type = each.value.encryption_type
  kms_key_name    = each.value.kms_key_name
  description     = each.value.description
  public_key      = each.value.public_key
  private_key     = each.value.private_key
  key_file        = each.value.key_file
}

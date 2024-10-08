output "kms_keys" {
  description = "KMS keys outputs"
  value = tomap({
    for k, kms_keys_output in huaweicloud_kms_key.kms_key : k => {
      id              = kms_keys_output.id
      key_id          = kms_keys_output.key_id
      key_state       = kms_keys_output.key_state
      rotation_number = kms_keys_output.rotation_number
    }
  })
}
output "kms_key_pairs" {
  description = "KMS key-pairs outputs"
  value = tomap({
    for k, kms_key_pairs_output in huaweicloud_kps_keypair.key_pairs : k => {
      id         = kms_key_pairs_output.id
      is_managed = kms_key_pairs_output.is_managed
    }
  })
}

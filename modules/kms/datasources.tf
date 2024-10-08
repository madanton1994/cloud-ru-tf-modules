locals {
  kms_key_local = distinct(flatten([
    for kms_key_name, kms_key_config in var.kms_keys : {
      region                = kms_key_config.region != null ? kms_key_config.region : null
      key_alias             = kms_key_name
      key_description       = kms_key_config.key_description != null ? kms_key_config.key_description : null
      key_algorithm         = kms_key_config.key_algorithm != null ? kms_key_config.key_algorithm : null
      pending_days          = kms_key_config.pending_days != null ? kms_key_config.pending_days : null
      is_enabled            = kms_key_config.is_enabled != null ? kms_key_config.is_enabled : true
      rotation_enabled      = kms_key_config.origin == "kms" ? true : false
      rotation_interval     = kms_key_config.rotation_enabled == true ? kms_key_config.rotation_interval : null
      enterprise_project_id = kms_key_config.enterprise_project_id != null ? kms_key_config.enterprise_project_id : null
      tags                  = kms_key_config.tags != null ? kms_key_config.tags : null
      origin                = kms_key_config.origin != null ? kms_key_config.origin : "kms"
      key_usage             = kms_key_config.key_usage != null ? kms_key_config.key_usage : null
      keystore_id           = kms_key_config.keystore_id != null ? kms_key_config.keystore_id : null
      name                  = kms_key_name
    }
  ]))
  key_pair_local = distinct(flatten([
    for kms_key_name, kms_key_config in var.kms_keys : [
      for key_pair_name, key_pair_config in kms_key_config.key_pairs : {
        region          = kms_key_config.region != null ? kms_key_config.region : null
        name            = key_pair_name
        scope           = key_pair_config.scope != null ? key_pair_config.scope : "user"
        encryption_type = key_pair_config.encryption_type != null ? key_pair_config.encryption_type : "default"
        kms_key_name    = key_pair_config.encryption_type != "kms" ? null : key_pair_config.kms_key_name == null ? kms_key_name : key_pair_config.kms_key_name
        description     = key_pair_config.description != null ? key_pair_config.description : null
        public_key      = key_pair_config.public_key != null ? key_pair_config.public_key : null
        private_key     = key_pair_config.private_key != null ? key_pair_config.private_key : null
        key_file        = key_pair_config.key_file != null ? key_pair_config.key_file : null
    }]
    ])
  )
}

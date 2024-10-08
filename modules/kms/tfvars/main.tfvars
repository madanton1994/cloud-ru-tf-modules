kms_keys = {
  develop_kms_node_pool_key_2 = {
    region                = "ru-moscow-1"
    key_description       = "KMS key for SSH access to nodes from nodePools"
    key_algorithm         = "AES_256"
    pending_days          = "7"
    is_enabled            = true
    rotation_enabled      = true
    rotation_interval     = 30
    enterprise_project_id = ""
    tags = {
      "subproject"    = "sbis"
      "resource-type" = "kms"
    }
    origin                = "kms"
    key_usage             = "ENCRYPT_DECRYPT"
    # keystore_id           = "string"
    key_pairs = {
      develop_kms_node_pool_keypair_2 = {
        region          = "ru-moscow-1"
        scope           = "account"
        encryption_type = "kms"
        # kms_key_name    = "string"
        description     = "KMS key for SSH access to nodes from nodePools"
        # public_key      = "string"
        # private_key     = "string"
        # key_file        = "string"
      }
    }
  }
}
# resource "null_resource" "set_initial_state" {
#   depends_on = [sbercloud_cce_cluster.cce_cluster]
#   for_each   = sbercloud_cce_cluster.cce_cluster
#   provisioner "local-exec" {
#     interpreter = ["bash", "-c"]
#     command     = "sleep 10"
#   }
# }


# resource "time_sleep" "wait" {
#   create_duration = "15s"

#   depends_on = [
#     sbercloud_cce_cluster.cce_cluster,
#     null_resource.set_initial_state
#   ]
# }



resource "sbercloud_cce_node_pool" "k8s_node_pool" {
  depends_on               = [sbercloud_cce_cluster.cce_cluster]
  for_each                 = { for node_pool in local.node_pools : "${var.project}.${var.environment}.${node_pool.name}" => node_pool }
  cluster_id               = data.sbercloud_cce_cluster.cluster[each.value.cluster_name].id
  name                     = "${var.project}-${var.environment}-${each.value.name}"
  os                       = each.value.os
  flavor_id                = each.value.flavor_id
  initial_node_count       = each.value.initial_node_count
  availability_zone        = each.value.availability_zone
  key_pair                 = each.value.key_pair
  password                 = each.value.password
  scall_enable             = each.value.scall_enable
  min_node_count           = each.value.min_node_count
  max_node_count           = each.value.max_node_count
  scale_down_cooldown_time = each.value.scale_down_cooldown_time
  priority                 = each.value.priority
  type                     = each.value.type
  max_pods                 = each.value.max_pods
  preinstall               = each.value.preinstall
  postinstall              = each.value.postinstall
  labels                   = each.value.labels

  # provisioner "file" {
  #   source      = "./files/sberinsur-ca.crt"
  #   destination = "/etc/pki/ca-trust/source/anchors/sberinsur-ca.crt"
  # }

  dynamic "taints" {
    for_each = each.value.taints != null ? tomap(each.value.taints) : {}
    content {
      key    = taints.value.key
      value  = taints.value.value != null ? taints.value.value : ""
      effect = taints.value.effect
    }
  }

  root_volume {
    size       = each.value.root_volume.size
    volumetype = each.value.root_volume.volumetype
  }

  dynamic "data_volumes" {
    for_each = each.value.data_volumes != null ? tomap(each.value.data_volumes) : {}
    content {
      size       = data_volumes.value.size
      volumetype = data_volumes.value.volumetype
      kms_key_id = data_volumes.value.kms_key_id != null ? data_volumes.kms_key_id : null
    }
  }

  dynamic "storage" {
    # for_each = each.value.data_volumes.storage != null ? tomap(each.value.data_volumes.storage) : {}
    for_each = each.value.storage != null ? [each.value.storage] : []

    content {
      dynamic "selectors" {
        for_each = storage.value.node_storage_configuration["selectors"]

        content {
          name                           = selectors.value["name"]
          type                           = selectors.value["type"]
          match_label_size               = selectors.value["match_label_size"]
          match_label_volume_type        = selectors.value["match_label_volume_type"]
          match_label_metadata_encrypted = selectors.value["match_label_metadata_encrypted"]
          match_label_metadata_cmkid     = selectors.value["match_label_metadata_cmkid"]
          match_label_count              = selectors.value["match_label_count"]
        }
      }

      dynamic "groups" {
        for_each = storage.value.node_storage_configuration["groups"]
        content {
          name           = groups.value["name"]
          selector_names = groups.value["selector_names"]
          cce_managed    = groups.value["cce_managed"]

          dynamic "virtual_spaces" {
            for_each = groups.value["virtual_spaces"]

            content {
              name            = virtual_spaces.value["name"]
              size            = virtual_spaces.value["size"]
              lvm_lv_type     = virtual_spaces.value["lvm_lv_type"]
              lvm_path        = virtual_spaces.value["lvm_path"]
              runtime_lv_type = virtual_spaces.value["runtime_lv_type"]
            }
          }
        }
      }
    }
  }
}

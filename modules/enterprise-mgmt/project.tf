resource "sbercloud_enterprise_project" "project" {
  for_each                = { for entry in local.enterprise_mgmt_data : "${entry.name}.${entry.enable}" => entry }
  name                    = each.value.name
  description             = each.value.description
  type                    = each.value.type
  enable                  = each.value.enable
  skip_disable_on_destroy = each.value.skip_disable_on_destroy
}

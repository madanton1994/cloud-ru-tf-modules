resource "huaweicloud_vpc" "vpc" {
  for_each              = { for entry in local.vpc : "${var.project}.${var.environment}.${entry.vpc_name}" => entry }
  name                  = "${var.project}-${var.environment}-${each.value.vpc_name}"
  description           = each.value.description
  cidr                  = each.value.cidr
  enterprise_project_id = each.value.enterprise_project_id
  tags                  = merge(var.default_tags, coalesce(each.value.tags, var.default_tags))
}

resource "huaweicloud_vpc_subnet" "cce_vpc_subnet" {
  depends_on  = [huaweicloud_vpc.vpc]
  for_each    = { for entry in local.vpc_subnet : "${var.project}.${var.environment}.${entry.vpc_name}.${entry.name}" => entry }
  name        = "${var.project}-${var.environment}-${each.value.name}"
  cidr        = each.value.cidr
  gateway_ip  = each.value.gateway_ip
  vpc_id      = huaweicloud_vpc.vpc["${var.project}.${var.environment}.${each.value.vpc_name}"].id
  ipv6_enable = each.value.ipv6_enable
  dhcp_enable = each.value.dhcp_enable
  dns_list    = each.value.dns_list
  tags        = merge(var.default_tags, coalesce(each.value.tags, var.default_tags))
}

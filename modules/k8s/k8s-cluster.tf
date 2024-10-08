resource "huaweicloud_cce_cluster" "cce_cluster" {
  for_each                         = { for k8s in local.cluster_config : "${var.project}.${var.environment}.${k8s.name}" => k8s }
  name                             = "${var.project}-${var.environment}-${each.value.name}"
  flavor_id                        = each.value.flavor_id
  vpc_id                           = each.value.vpc_id
  subnet_id                        = each.value.subnet_id
  container_network_type           = each.value.container_network_type
  cluster_version                  = each.value.cluster_version
  cluster_type                     = each.value.cluster_type
  description                      = each.value.description
  container_network_cidr           = each.value.container_network_cidr
  service_network_cidr             = each.value.service_network_cidr
  eni_subnet_id                    = each.value.container_network_type == "eni" ? each.value.eni_subnet_id : null
  eni_subnet_cidr                  = each.value.container_network_type == "eni" ? each.value.eni_subnet_cidr : null
  authentication_mode              = each.value.authentication_mode
  authenticating_proxy_ca          = each.value.authenticating_proxy_ca
  authenticating_proxy_cert        = each.value.authenticating_proxy_cert
  authenticating_proxy_private_key = each.value.authenticating_proxy_private_key
  multi_az                         = each.value.multi_az


  # Dynamic section check multi_az var, if multi_az is false, use dynamic section for use custom setting AZs
  # if multi_az is true use random master AZs
  dynamic "masters" {
    for_each = each.value.multi_az == null ? toset(each.value.masters) : []
    content {
      availability_zone = masters.value
    }
  }

  eip                   = each.value.eip
  kube_proxy_mode       = each.value.kube_proxy_mode
  extend_param          = each.value.extend_param
  enterprise_project_id = each.value.enterprise_project_id
  tags                  = each.value.tags
  delete_evs            = each.value.delete_evs
  delete_obs            = each.value.delete_obs
  delete_sfs            = each.value.delete_sfs
  delete_efs            = each.value.delete_efs
  delete_all            = each.value.delete_all
  hibernate             = each.value.hibernate
}

data "sbercloud_vpcs" "vpc" {
  enterprise_project_id = var.enterprise_project_id
  tags = {
    data-selector = "k8s-vpc"
    project       = "sberinsur"
    subproject    = "claims"
    managed       = "terraform"
  }
}

data "sbercloud_vpc" "vpc" {
  for_each = { for vpc_data in data.sbercloud_vpcs.vpc.vpcs : "${vpc_data.id}" => vpc_data }
  id       = each.value.id
}

data "sbercloud_vpc_subnets" "subnet_masters" {
  for_each = { for vpc_data in data.sbercloud_vpcs.vpc.vpcs : "${vpc_data.id}" => vpc_data }
  vpc_id   = each.value.id
  tags = {
    subproject    = "claims"
    resource-type = "subnet"
    data-selector = "k8s-cce-subnet"
  }
}
data "sbercloud_vpc_subnets" "subnet_eni" {
  for_each = { for vpc_data in data.sbercloud_vpcs.vpc.vpcs : "${vpc_data.id}" => vpc_data }
  vpc_id   = each.value.id
  tags = {
    subproject    = "claims"
    resource-type = "subnet"
    data-selector = "k8s-cce-subnet-eni"
  }
}

locals {
  cluster_config = distinct(flatten([
    for k8s_cluster_name, k8s_cluster_config in var.k8s_cluster : [
      for vpc_data in data.sbercloud_vpc.vpc : [
        for subnet_masters in data.sbercloud_vpc_subnets.subnet_masters : [
          for subnet_eni in data.sbercloud_vpc_subnets.subnet_eni : {
            name                             = k8s_cluster_name
            flavor_id                        = k8s_cluster_config.flavor_id
            vpc_id                           = vpc_data.id
            subnet_id                        = subnet_masters.subnets[0].id
            container_network_type           = k8s_cluster_config.container_network_type
            region                           = k8s_cluster_config.region
            cluster_version                  = k8s_cluster_config.cluster_version != null ? k8s_cluster_config.cluster_version : null
            cluster_type                     = k8s_cluster_config.cluster_type == null ? "VirtualMachine" : k8s_cluster_config.cluster_type
            description                      = k8s_cluster_config.description
            container_network_cidr           = k8s_cluster_config.container_network_type != "eni" ? k8s_cluster_config.container_network_cidr : null
            service_network_cidr             = k8s_cluster_config.service_network_cidr != null ? k8s_cluster_config.service_network_cidr : null
            eni_subnet_id                    = k8s_cluster_config.eni_subnet_id != null ? k8s_cluster_config.eni_subnet_id : subnet_eni.subnets[0].ipv4_subnet_id
            eni_subnet_cidr                  = k8s_cluster_config.eni_subnet_cidr != null ? k8s_cluster_config.eni_subnet_cidr : subnet_eni.subnets[0].cidr
            authentication_mode              = k8s_cluster_config.authentication_mode == null ? "rbac" : k8s_cluster_config.authentication_mode
            authenticating_proxy_ca          = k8s_cluster_config.authentication_mode == "authenticating_proxy" ? k8s_cluster_config.authenticating_proxy_ca : null
            authenticating_proxy_cert        = k8s_cluster_config.authentication_mode == "authenticating_proxy" ? k8s_cluster_config.authenticating_proxy_cert : null
            authenticating_proxy_private_key = k8s_cluster_config.authentication_mode == "authenticating_proxy" ? k8s_cluster_config.authenticating_proxy_private_key : null
            multi_az                         = k8s_cluster_config.masters != null ? k8s_cluster_config.multi_az : null
            masters                          = k8s_cluster_config.multi_az != null ? [] : k8s_cluster_config.masters == null ? [] : k8s_cluster_config.masters
            eip                              = k8s_cluster_config.eip != null ? k8s_cluster_config.eip : null
            kube_proxy_mode                  = k8s_cluster_config.kube_proxy_mode == null ? "iptables" : k8s_cluster_config.kube_proxy_mode
            extend_param                     = k8s_cluster_config.extend_param == null ? {} : k8s_cluster_config.extend_param
            enterprise_project_id            = k8s_cluster_config.enterprise_project_id == null ? null : k8s_cluster_config.enterprise_project_id
            tags                             = merge(var.default_tags, coalesce(k8s_cluster_config.tags, var.default_tags))
            delete_evs                       = k8s_cluster_config.delete_all != null ? null : k8s_cluster_config.delete_evs == null ? "false" : k8s_cluster_config.delete_evs
            delete_obs                       = k8s_cluster_config.delete_all != null ? null : k8s_cluster_config.delete_obs == null ? "false" : k8s_cluster_config.delete_obs
            delete_sfs                       = k8s_cluster_config.delete_all != null ? null : k8s_cluster_config.delete_sfs == null ? "false" : k8s_cluster_config.delete_sfs
            delete_efs                       = k8s_cluster_config.delete_all != null ? null : k8s_cluster_config.delete_efs == null ? "false" : k8s_cluster_config.delete_efs
            delete_all                       = k8s_cluster_config.delete_all != null ? k8s_cluster_config.delete_all : null
            hibernate                        = k8s_cluster_config.hibernate != null ? k8s_cluster_config.hibernate : null
          }
        ]
      ]
    ]
  ]))
}

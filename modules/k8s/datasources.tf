data "huaweicloud_vpcs" "vpc" {
  enterprise_project_id = var.enterprise_project_id
}

data "huaweicloud_vpc" "vpc" {
  for_each = { for vpc_data in data.huaweicloud_vpcs.vpc.vpcs : "${vpc_data.id}" => vpc_data }
  id       = each.value.id
}

data "huaweicloud_vpc_subnets" "subnet_masters" {
  for_each = { for vpc_data in data.huaweicloud_vpcs.vpc.vpcs : "${vpc_data.id}" => vpc_data }
  vpc_id   = each.value.id
  tags = {
    "data-selector" = "k8s-cce-subnet"
  }
}

data "huaweicloud_vpc_subnets" "subnet_eni" {
  for_each = { for vpc_data in data.huaweicloud_vpcs.vpc.vpcs : "${vpc_data.id}" => vpc_data }
  vpc_id   = each.value.id
  tags = {
    "data-selector" = "k8s-cce-subnet-eni"
  }

}
data "huaweicloud_cce_clusters" "clusters" {
  depends_on = [huaweicloud_cce_cluster.cce_cluster]
  for_each   = { for k8s in local.cluster_config : "${k8s.name}" => k8s }
  name       = each.value.name
}

data "huaweicloud_cce_cluster" "cluster" {
  depends_on = [data.huaweicloud_cce_clusters.clusters]
  for_each   = { for clusters in data.huaweicloud_cce_clusters.clusters : "${var.project}-${var.environment}-${clusters.name}" => clusters }
  name       = each.key
  # status   = "Available"
}


# data "huaweicloud_cce_cluster" "cluster_name_id" {
#   depends_on = [huaweicloud_cce_cluster.cce_cluster]
#   for_each   = { for cluster_name, cluster_config in var.k8s_cluster : "${cluster_name}" => cluster_name }
#   name       = each.key
# }

# data "huaweicloud_cce_cluster" "cluster" {
#   depends_on = [  ]
#   for_each = { for k8s_cluster_config in var.k8s_cluster : "${k8s_cluster_config.name}" => k8s_cluster_config }
#   name     = each.value.name
# }

locals {
  cluster_config = distinct(flatten([
    for k8s_cluster_name, k8s_cluster_config in var.k8s_cluster : [
      for vpc_data in data.huaweicloud_vpc.vpc : [
        for subnet_masters in data.huaweicloud_vpc_subnets.subnet_masters : [
          for subnet_eni in data.huaweicloud_vpc_subnets.subnet_eni : {
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

  node_pools = distinct(flatten([
    for k8s_cluster_name, k8s_cluster_config in var.k8s_cluster : [
      for k8s_node_pool_name, k8s_node_pool_config in k8s_cluster_config.node_pools : [
        for subnet_masters in data.huaweicloud_vpc_subnets.subnet_masters : [
          for key_pair_name, key_pair_data in var.kms_key_pairs : [
            for cluster_data_id in data.huaweicloud_cce_cluster.cluster : {
              region = k8s_cluster_config.region
              name                     = k8s_node_pool_name
              initial_node_count       = k8s_node_pool_config.initial_node_count
              flavor_id                = k8s_node_pool_config.flavor_id
              type                     = k8s_node_pool_config.type
              availability_zone        = k8s_node_pool_config.availability_zone
              os                       = k8s_node_pool_config.os
              # key_pair                 = k8s_node_pool_config.password == null ? var.kms_key_pairs["sberinsur.develop.develop_kms_node_pool_keypair_k8s"].id : null
              password                 = k8s_node_pool_config.key_pair != null ? null : k8s_node_pool_config.password == null ? null : k8s_node_pool_config.password
              subnet_id                = subnet_masters.subnets[0].id
              max_pods                 = k8s_node_pool_config.max_pods != null ? k8s_node_pool_config.max_pods : null
              ecs_group_id             = k8s_node_pool_config.ecs_group_id
              preinstall               = k8s_node_pool_config.preinstall != null ? k8s_node_pool_config.preinstall : null   #The input value can be a Base64 encoded string or not
              postinstall              = k8s_node_pool_config.postinstall != null ? k8s_node_pool_config.postinstall : null #The input value can be a Base64 encoded string or not
              extend_param             = k8s_node_pool_config.extend_param
              scall_enable             = k8s_node_pool_config.scall_enable
              min_node_count           = k8s_node_pool_config.min_node_count
              max_node_count           = k8s_node_pool_config.max_node_count
              scale_down_cooldown_time = k8s_node_pool_config.scale_down_cooldown_time
              priority                 = k8s_node_pool_config.priority
              security_groups          = k8s_node_pool_config.security_groups
              pod_security_groups      = k8s_node_pool_config.pod_security_groups
              labels                   = k8s_node_pool_config.labels
              tags                     = merge(var.default_tags, coalesce(k8s_node_pool_config.tags, var.default_tags))
              root_volume              = k8s_node_pool_config.root_volume
              data_volumes             = k8s_node_pool_config.data_volumes
              charging_mode            = k8s_node_pool_config.charging_mode
              period_unit              = k8s_node_pool_config.period_unit
              period                   = k8s_node_pool_config.period
              auto_renew               = k8s_node_pool_config.auto_renew
              runtime                  = k8s_node_pool_config.runtime
              taints                   = k8s_node_pool_config.taints == null ? {} : k8s_node_pool_config.taints
              storage                  = k8s_node_pool_config.storage
              cluster_name             = "${var.project}-${var.environment}-${k8s_cluster_name}"
              key_pair_name = key_pair_name
            }
          ]
        ]
      ]
    ]
  ]))




  nlb_config = distinct(flatten([
    for nlb_name, nlb_config in var.nlb_config : [
      for subnet_ingress_nodes in data.huaweicloud_vpc_subnets.subnet_masters : {
        name                  = nlb_name
        description           = nlb_config.description == null ? null : nlb_config.description
        vip_subnet_id         = nlb_config.vip_subnet_id == null ? subnet_ingress_nodes.subnets[0].ipv4_subnet_id : nlb_config.vip_subnet_id
        vip_address           = nlb_config.vip_address == null ? null : nlb_config.vip_address
        enterprise_project_id = nlb_config.enterprise_project_id == null ? null : nlb_config.enterprise_project_id
        tags                  = merge(var.default_tags, coalesce(nlb_config.tags, var.default_tags))
        admin_state_up        = nlb_config.admin_state_up != true ? nlb_config.admin_state_up : true
        listeners             = nlb_config.listeners
      }
    ]
  ]))

  listener_config = distinct(flatten([
    for nlb_name, nlb_config in var.nlb_config : [
      for listener_name, listener_config in nlb_config.listeners : {
        name                      = listener_name
        protocol                  = listener_config.protocol
        protocol_port             = listener_config.protocol_port
        default_pool_id           = listener_config.default_pool_id == null ? null : listener_config.default_pool_id
        description               = listener_config.description == null ? null : listener_config.description
        connection_limit          = listener_config.connection_limit == null ? null : listener_config.connection_limit
        http2_enable              = listener_config.http2_enable == null ? null : listener_config.http2_enable
        default_tls_container_ref = listener_config.default_tls_container_ref == null ? null : listener_config.default_tls_container_ref
        sni_container_refs        = listener_config.sni_container_refs == null ? null : listener_config.sni_container_refs
        admin_state_up            = listener_config.admin_state_up != true ? listener_config.admin_state_up : true
        tags                      = merge(var.default_tags, coalesce(listener_config.tags, var.default_tags))
        nlb_index_name            = nlb_name
      }
    ]
  ]))

  target_group_config = distinct(flatten([
    for nlb_name, nlb_config in var.nlb_config : [
      for listener_name, listener_config in nlb_config.listeners : [
        for target_group_name, target_group_config in listener_config.target_groups : {
          name             = target_group_name
          description      = target_group_config.description == null ? null : target_group_config.description
          protocol         = target_group_config.protocol
          lb_method        = target_group_config.lb_method
          persistence      = target_group_config.persistence
          listener_id_name = listener_name
          nlb_index_name   = nlb_name
        }
      ]
    ]
  ]))

}

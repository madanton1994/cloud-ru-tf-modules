resource "sbercloud_lb_loadbalancer" "nlb" {
  depends_on            = [sbercloud_cce_node_pool.k8s_node_pool]
  for_each              = { for nlb in local.nlb_config : "${var.project}.${var.environment}.${nlb.name}" => nlb }
  enterprise_project_id = each.value.enterprise_project_id
  description           = each.value.description
  name                  = "${var.project}-${var.environment}-${each.value.name}"
  vip_subnet_id         = each.value.vip_subnet_id
  vip_address           = each.value.vip_address
  admin_state_up        = each.value.admin_state_up
  tags                  = each.value.tags
}

resource "sbercloud_lb_listener" "listener" {
  depends_on    = [sbercloud_lb_loadbalancer.nlb]
  for_each      = { for listener in local.listener_config : "${var.project}.${var.environment}.${listener.nlb_index_name}.${listener.name}" => listener }
  name          = "listener_${each.value.protocol}_${each.value.protocol_port}"
  protocol      = each.value.protocol
  protocol_port = each.value.protocol_port
  # loadbalancer_id           = each.value.loadbalancer_id
  loadbalancer_id           = sbercloud_lb_loadbalancer.nlb["${var.project}.${var.environment}.${each.value.nlb_index_name}"].id
  default_pool_id           = each.value.default_pool_id
  description               = each.value.description
  connection_limit          = each.value.connection_limit
  http2_enable              = each.value.http2_enable
  default_tls_container_ref = each.value.default_tls_container_ref
  sni_container_refs        = each.value.sni_container_refs
  admin_state_up            = each.value.admin_state_up
  tags                      = each.value.tags
}

resource "sbercloud_lb_pool" "target_group" {
  depends_on  = [sbercloud_lb_listener.listener, sbercloud_lb_loadbalancer.nlb]
  for_each    = { for target_group in local.target_group_config : "${var.project}.${var.environment}.${target_group.nlb_index_name}.${target_group.listener_id_name}.${target_group.name}" => target_group }
  name        = each.value.name
  protocol    = each.value.protocol
  lb_method   = each.value.lb_method
  listener_id = sbercloud_lb_listener.listener["${var.project}.${var.environment}.${each.value.nlb_index_name}.${each.value.listener_id_name}"].id
  dynamic "persistence" {
    for_each = each.value.persistence != null ? tomap(each.value.persistence) : {}
    content {
      type        = persistance.type
      cookie_name = persistance.cookie_name
      timeout     = persistance.timeout
    }
  }
}

# data "sbercloud_cce_node_pool" "node_ingress" {
#   for_each   = { for ingrress_node_pool in data.sbercloud_cce_cluster.cluster : "${ingrress_node_pool.name}" => ingrress_node_pool }
#   cluster_id = each.value["claims-cce-cluster"].cluster_id
#   # name       = each.value.name.
# }

# resource "sbercloud_cce_addon" "addon" {
#   cluster_id    = "7c673a70-9da0-11ee-a27f-0255ac100046"
#   template_name = "tigera-operator"
#   version       = "3.25.1"
# }


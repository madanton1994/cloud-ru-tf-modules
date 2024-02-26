variable "vpc_input" {
  type = map(any)
}

variable "enterprise_project_id" {}
variable "environment" {}
variable "project" {}


variable "iam_access_key" {
  description = "IAM access key"

  type      = string
  sensitive = true
  default   = ""
}
variable "iam_secret_key" {
  description = "IAM secret key"

  type      = string
  sensitive = true
  default   = ""
}


variable "default_tags" {
  description = "Default tags"
  type        = map(string)
}

variable "k8s_cluster" {
  description = "K8s cluster settings"
  type = map(object({
    # name      = string
    flavor_id = string
    # vpc_id                           = string
    # subnet_id                        = string
    container_network_type           = string
    region                           = optional(string)
    cluster_version                  = optional(string)
    cluster_type                     = optional(string)
    description                      = optional(string)
    container_network_cidr           = optional(string)
    service_network_cidr             = optional(string)
    eni_subnet_id                    = optional(string)
    eni_subnet_cidr                  = optional(string)
    authentication_mode              = optional(string)
    authenticating_proxy_ca          = optional(string)
    authenticating_proxy_cert        = optional(string)
    authenticating_proxy_private_key = optional(string)
    multi_az                         = optional(bool)
    masters                          = optional(list(string))
    eip                              = optional(string)
    kube_proxy_mode                  = optional(string)
    extend_param                     = optional(map(string))
    enterprise_project_id            = optional(string)
    tags                             = optional(map(string))
    delete_evs                       = optional(string)
    delete_obs                       = optional(string)
    delete_sfs                       = optional(string)
    delete_efs                       = optional(string)
    delete_all                       = optional(string)
    hibernate                        = optional(string)
    node_pools = optional(map(object({
      region = optional(string)
      # cluster_id               = string
      # name                     = string
      initial_node_count       = number
      flavor_id                = string
      type                     = optional(string)
      availability_zone        = optional(string)
      os                       = optional(string)
      key_pair                 = optional(string)
      password                 = optional(string)
      subnet_id                = optional(string)
      max_pods                 = optional(number)
      ecs_group_id             = optional(string)
      preinstall               = optional(string) #The input value can be a Base64 encoded string or not
      postinstall              = optional(string) #The input value can be a Base64 encoded string or not
      extend_param             = optional(map(string))
      scall_enable             = optional(bool)
      min_node_count           = optional(number)
      max_node_count           = optional(number)
      scale_down_cooldown_time = optional(number)
      priority                 = optional(number)
      security_groups          = optional(list(string))
      pod_security_groups      = optional(list(string))
      labels                   = optional(map(string))
      tags                     = optional(map(string))
      root_volume              = map(string)
      data_volumes = map(object({
        size          = number
        volumetype    = string
        extend_params = optional(string)
        kms_key_id    = optional(string)
      }))

      storage = optional(map(object({
        selectors = optional(list(object({
          name                           = string
          type                           = optional(string, "evs")
          match_label_size               = optional(number, 100)
          match_label_volume_type        = optional(string, null)
          match_label_metadata_encrypted = optional(string, null)
          match_label_metadata_cmkid     = optional(string, null)
          match_label_count              = optional(number, null)
        })), null)
        groups = optional(list(object({
          name           = string
          selector_names = list(string)
          cce_managed    = optional(string, null)
          virtual_spaces = list(object({
            name            = string
            size            = string
            lvm_lv_type     = optional(string, null)
            lvm_path        = optional(string, null)
            runtime_lv_type = optional(string, null)
          }))
        })), null)
      })))

      charging_mode = optional(string)
      period_unit   = optional(string)
      period        = optional(number)
      auto_renew    = optional(string)
      runtime       = string
      taints = optional(map(object({
        key    = string
        value  = optional(string)
        effect = string
      })))
    })))
  }))

  # cidr                  = string
  # enterprise_project_id = optional(string)
  # tags                  = optional(map(string))
  # vpc_subnets = map(object({
  #   name        = string
  #   description = optional(string)
  #   cidr        = string
  #   gateway_ip  = string
  #   # vpc_id            = string
  #   region            = optional(string)
  #   primary_dns       = optional(string)
  #   secondary_dns     = optional(string)
  #   ipv6_enable       = optional(bool)
  #   dhcp_enable       = optional(bool)
  #   dns_list          = optional(list(string))
  #   availability_zone = optional(string)
  #   tags              = optional(map(string))
  # }))

}

# variable "enterprise_project_id" {
#   type = string
# }

variable "nlb_config" {
  description = "value"
  type = map(object({
    name                  = optional(string)
    enterprise_project_id = optional(string)
    description           = optional(string)
    vip_subnet_id         = optional(string)
    vip_address           = optional(string)
    admin_state_up        = optional(bool)
    tags                  = optional(map(string))
    listeners = optional(map(object({
      region                    = optional(string)
      protocol                  = string
      protocol_port             = number
      name                      = optional(string)
      default_pool_id           = optional(string)
      description               = optional(string)
      connection_limit          = optional(number)
      http2_enable              = optional(bool)
      default_tls_container_ref = optional(string)
      sni_container_refs        = optional(list(string))
      admin_state_up            = optional(bool)
      nlb_index_name            = optional(string)
      tags                      = optional(map(string))
      target_groups = optional(map(object({
        region           = optional(string)
        name             = optional(string)
        description      = optional(string)
        protocol         = string
        loadbalancer_id  = optional(string)
        listener_id      = optional(string)
        listener_id_name = optional(string)
        nlb_index_name   = optional(string)
        lb_method        = string
        admin_state_up   = optional(bool)
        persistence = optional(map(object({
          type        = string
          cookie_name = optional(string)
          timeout     = optional(number)
        })))
      })))
    })))

  }))
}

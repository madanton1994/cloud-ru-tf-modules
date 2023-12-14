variable "vpc_input" {
  type = map(any)
}

variable "enterprise_project_id" {}

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
    name      = string
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

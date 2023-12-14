locals {
  vpc = distinct(flatten([
    for vpc_name, vpc_config in var.network : {
      vpc_name              = vpc_name
      description           = vpc_config.description
      cidr                  = vpc_config.cidr
      enterprise_project_id = vpc_config.enterprise_project_id
      tags                  = vpc_config.tags
    }
  ]))

  vpc_subnet = distinct(flatten([
    for vpc_name, vpc_config in var.network : [
      for subnet_name, subnet_config in vpc_config.vpc_subnets : {
        description = subnet_config.description
        name        = subnet_name
        cidr        = subnet_config.cidr
        gateway_ip  = subnet_config.gateway_ip
        ipv6_enable = subnet_config.ipv6_enable
        dhcp_enable = subnet_config.dhcp_enable
        dns_list    = subnet_config.dns_list
        tags        = subnet_config.tags
        vpc_name    = vpc_name
    }]
  ]))
}


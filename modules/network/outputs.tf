output "vpc" {
  description = "value"
  value = tomap({
    for k, vpc_output in sbercloud_vpc.vpc : k => {
      id     = vpc_output.id
      status = vpc_output.status
      cidr   = vpc_output.cidr
    }
  })
}
output "vpc_subnet" {
  description = "value"
  value = tomap({
    for k, subnet_output in sbercloud_vpc_subnet.cce_vpc_subnet : k => {
      id         = subnet_output.id
      name       = subnet_output.name
      cidr       = subnet_output.cidr
      gateway_ip = subnet_output.gateway_ip
      vpc_id     = subnet_output.vpc_id

    }
  })
}

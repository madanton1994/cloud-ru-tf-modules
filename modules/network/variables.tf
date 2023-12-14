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

variable "network" {
  description = "Network"
  type = map(object({
    description           = optional(string)
    name                  = string
    cidr                  = string
    enterprise_project_id = optional(string)
    tags                  = optional(map(string))
    vpc_subnets = map(object({
      name        = string
      description = optional(string)
      cidr        = string
      gateway_ip  = string
      # vpc_id            = string
      region            = optional(string)
      primary_dns       = optional(string)
      secondary_dns     = optional(string)
      ipv6_enable       = optional(bool)
      dhcp_enable       = optional(bool)
      dns_list          = optional(list(string))
      availability_zone = optional(string)
      tags              = optional(map(string))
    }))

  }))
}

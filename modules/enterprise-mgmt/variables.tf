variable "iam_access_key" {
  description = "IAM access key"
  type        = string
  sensitive   = true
  default     = ""
}
variable "iam_secret_key" {
  description = "IAM secret key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "enterprise_mgmt" {
  description = "Enterprise project management"
  type = map(object({
    description             = string
    name                    = string
    type                    = string
    enable                  = bool
    skip_disable_on_destroy = bool
  }))
}

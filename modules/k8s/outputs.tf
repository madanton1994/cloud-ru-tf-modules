# output "enterprise_mgmt_project_id" {
#   description = "Project ID"
#   # value       = sbercloud_enterprise_project.project[each.key].id
#   # value = {
#   #   for k, id in sbercloud_enterprise_project.project.id : k => bd.name
#   # }
#   value = toset([
#     for id in sbercloud_enterprise_project.project : id.id
#   ])
# }

# # output "enterprise_mgmt_project_status" {
# #   description = "Project Status"
# #   value       = sbercloud_enterprise_project.project[each.key].status
# # }

# output "vpc" {
#   description = "value"
#   value = tomap({
#     for k, vpc_output in sbercloud_vpc.vpc : k => {
#       id     = vpc_output.id
#       status = vpc_output.status
#     }
#   })
#   # value       = sbercloud_vpc.vpc.id
# }


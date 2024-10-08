# output "enterprise_mgmt_project_id" {
#   description = "Project ID"
#   # value       = huaweicloud_enterprise_project.project[each.key].id
#   # value = {
#   #   for k, id in huaweicloud_enterprise_project.project.id : k => bd.name
#   # }
#   value = toset([
#     for id in huaweicloud_enterprise_project.project : id.id
#   ])
# }

# # output "enterprise_mgmt_project_status" {
# #   description = "Project Status"
# #   value       = huaweicloud_enterprise_project.project[each.key].status
# # }

# output "vpc" {
#   description = "value"
#   value = tomap({
#     for k, vpc_output in huaweicloud_vpc.vpc : k => {
#       id     = vpc_output.id
#       status = vpc_output.status
#     }
#   })
#   # value       = huaweicloud_vpc.vpc.id
# }


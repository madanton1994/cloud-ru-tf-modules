output "enterprise_mgmt_project_id" {
  description = "Project ID"
  value       = [for project in sbercloud_enterprise_project.project : project.id]
}

output "enterprise_mgmt_project_status" {
  description = "Project Status"
  value       = [for project in sbercloud_enterprise_project.project : project.status]
}

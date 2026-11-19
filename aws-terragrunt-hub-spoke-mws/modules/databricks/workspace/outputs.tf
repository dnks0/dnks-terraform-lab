output "workspace_id" {
  description = "Databricks workspace ID"
  value       = databricks_mws_workspaces.this.workspace_id
}

output "workspace_host" {
  description = "Databricks workspace URL"
  value       = databricks_mws_workspaces.this.workspace_url
}

output "workspace_name" {
  description = "Databricks workspace name"
  value       = databricks_mws_workspaces.this.workspace_name
}

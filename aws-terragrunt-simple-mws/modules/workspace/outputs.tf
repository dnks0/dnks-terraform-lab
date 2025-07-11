output "workspace_id" {
  value = databricks_mws_workspaces.this.workspace_id
}

output "workspace_host" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "workspace_name" {
  value = databricks_mws_workspaces.this.workspace_name
}

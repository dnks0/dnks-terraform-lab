output "workspace_id" {
  value = azurerm_databricks_workspace.this.workspace_id
}

output "workspace_host" {
  value = azurerm_databricks_workspace.this.workspace_url
}

output "workspace_name" {
  value = "${var.prefix}-workspace"
}

output "azure_resource_group_name" {
  value = azurerm_resource_group.this.name
}

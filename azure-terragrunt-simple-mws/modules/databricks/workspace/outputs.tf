output "workspace_id" {
  value = azurerm_databricks_workspace.this.workspace_id
}

output "workspace_host" {
  value = azurerm_databricks_workspace.this.workspace_url
}

output "workspace_name" {
  value = "${var.prefix}-workspace"
}

# Pass-through: the RG is now owned by the network unit and supplied as an input.
# Kept as an output so downstream units (workspace-config, sat) consume it unchanged.
output "azure_resource_group_name" {
  value = var.resource_group_name
}

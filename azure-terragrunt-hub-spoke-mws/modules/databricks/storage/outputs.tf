output "access_connector_id" {
  description = "ID of the Databricks access connector (managed identity)"
  value       = azurerm_databricks_access_connector.this.id
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "storage_account_dfs_host" {
  description = "Primary DFS host of the storage account"
  value       = azurerm_storage_account.this.primary_dfs_host
}

output "storage_container_name" {
  description = "Name of the storage container"
  value       = azurerm_storage_container.this.name
}

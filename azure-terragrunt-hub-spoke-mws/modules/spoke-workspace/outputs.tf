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

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Subnet IDs"
  value = {
    host        = azurerm_subnet.host.id
    container   = azurerm_subnet.container.id
    privatelink = azurerm_subnet.privatelink.id
  }
}

output "subnet_cidrs" {
  description = "Subnet CIDRs"
  value = {
    host        = azurerm_subnet.host.address_prefixes
    container   = azurerm_subnet.container.address_prefixes
    privatelink = azurerm_subnet.privatelink.address_prefixes
  }
}

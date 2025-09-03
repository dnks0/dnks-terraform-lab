output "azure_resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "route_table_id" {
  value = azurerm_route_table.this.id
}

output "ipgroup_id" {
  value = azurerm_ip_group.this.id
}

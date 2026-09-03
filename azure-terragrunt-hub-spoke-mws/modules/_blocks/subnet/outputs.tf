output "id" {
  value = azurerm_subnet.this.id
}

output "name" {
  value = azurerm_subnet.this.name
}

output "address_prefixes" {
  value = azurerm_subnet.this.address_prefixes
}

# Empty string when no NSG association exists — stable output shape.
output "network_security_group_association_id" {
  value = one(azurerm_subnet_network_security_group_association.this[*].id) == null ? "" : one(azurerm_subnet_network_security_group_association.this[*].id)
}

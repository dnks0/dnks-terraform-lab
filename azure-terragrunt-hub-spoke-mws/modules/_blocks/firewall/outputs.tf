output "id" {
  value = azurerm_firewall.this.id
}

output "firewall_policy_id" {
  value = azurerm_firewall_policy.this.id
}

output "private_ip_address" {
  value = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

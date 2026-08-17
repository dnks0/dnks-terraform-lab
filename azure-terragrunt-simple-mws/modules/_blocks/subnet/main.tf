# _blocks/subnet — a single subnet plus its optional delegation, NSG association and NAT association.
# These are 1:1 with the subnet, so they live together as one atomic unit.

resource "azurerm_subnet" "this" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes

  dynamic "delegation" {
    for_each = var.delegation == null ? [] : [var.delegation]
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count                     = var.network_security_group_id == null ? 0 : 1
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  count          = var.nat_gateway_id == null ? 0 : 1
  subnet_id      = azurerm_subnet.this.id
  nat_gateway_id = var.nat_gateway_id
}

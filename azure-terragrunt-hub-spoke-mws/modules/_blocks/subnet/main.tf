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

# Associations are gated on explicit booleans (known at plan time) rather than on the
# target IDs, which may be unknown until apply (e.g. an NSG created in the same run or a
# NAT ID passed from a dependency). Gating on the IDs would raise "Invalid count argument".
resource "azurerm_subnet_network_security_group_association" "this" {
  count                     = var.associate_network_security_group ? 1 : 0
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  count          = var.associate_nat_gateway ? 1 : 0
  subnet_id      = azurerm_subnet.this.id
  nat_gateway_id = var.nat_gateway_id
}

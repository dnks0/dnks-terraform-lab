# _blocks/vnet — a single Azure virtual network.
# Generic, purpose-agnostic. Subnets/NSGs/NAT are separate blocks.

resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  lifecycle {
    ignore_changes = [tags]
  }

  tags = var.tags
}

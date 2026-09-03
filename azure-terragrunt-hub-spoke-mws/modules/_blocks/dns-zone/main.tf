# _blocks/dns-zone — a private DNS zone plus its link to a virtual network.
# Zone + vnet-link are atomic (a zone with no link is not useful here).

resource "azurerm_private_dns_zone" "this" {
  name                = var.zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                = var.link_name
  private_dns_zone_id = azurerm_private_dns_zone.this.id
  virtual_network_id  = var.virtual_network_id
  tags                = var.tags
}

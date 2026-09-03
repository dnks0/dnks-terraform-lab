# Generic IP group. CIDR entries may be supplied here, or added incrementally elsewhere via
# azurerm_ip_group_cidr (as the hub-spoke-config module does for the spoke subnets).
resource "azurerm_ip_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  cidrs               = var.cidrs
  tags                = var.tags
}

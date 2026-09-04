# Bidirectional VNet peering pair. "left" and "right" are the two peered networks
# (in this stack: left = spoke, right = hub).
resource "azurerm_virtual_network_peering" "left_to_right" {
  name                      = var.left_to_right_name != "" ? var.left_to_right_name : "from-${var.left_vnet_name}-to-${var.right_vnet_name}-peering"
  resource_group_name       = var.left_resource_group_name
  virtual_network_name      = var.left_vnet_name
  remote_virtual_network_id = var.right_vnet_id
}

resource "azurerm_virtual_network_peering" "right_to_left" {
  name                      = var.right_to_left_name != "" ? var.right_to_left_name : "from-${var.right_vnet_name}-to-${var.left_vnet_name}-peering"
  resource_group_name       = var.right_resource_group_name
  virtual_network_name      = var.right_vnet_name
  remote_virtual_network_id = var.left_vnet_id
}

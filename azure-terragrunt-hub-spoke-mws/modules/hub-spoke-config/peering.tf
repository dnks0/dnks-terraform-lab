# Create a virtual network peering from the spoke network to the hub network
resource "azurerm_virtual_network_peering" "spoke-to-hub" {
  name                      = format("from-%s-to-hub-peering", var.spoke_vnet_name)
  resource_group_name       = var.spoke_resource_group_name
  virtual_network_name      = var.spoke_vnet_name
  remote_virtual_network_id = var.hub_vnet_id
}

# Create a virtual network peering from the hub network to the spoke network
resource "azurerm_virtual_network_peering" "hub-to-spoke" {
  name                      = format("from-hub-to-%s-peering", var.spoke_vnet_name)
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = var.spoke_vnet_id
}

# Associate the route table with the host subnet
resource "azurerm_subnet_route_table_association" "host" {
  subnet_id      = var.spoke_subnet_ids.host
  route_table_id = var.hub_route_table_id

  depends_on = [azurerm_virtual_network_peering.hub-to-spoke, azurerm_virtual_network_peering.spoke-to-hub]
}

# Associate the route table with the container subnet
resource "azurerm_subnet_route_table_association" "container" {
  subnet_id      = var.spoke_subnet_ids.container
  route_table_id = var.hub_route_table_id

  depends_on = [azurerm_virtual_network_peering.hub-to-spoke, azurerm_virtual_network_peering.spoke-to-hub]
}

# Assign the host subnet CIDR to the IP group
resource "azurerm_ip_group_cidr" "host" {
  ip_group_id = var.hub_ipgroup_id
  cidr        = var.spoke_subnet_cidrs.host[0]
}

# Assign the container subnet CIDR to the IP group
resource "azurerm_ip_group_cidr" "container" {
  ip_group_id = var.hub_ipgroup_id
  cidr        = var.spoke_subnet_cidrs.container[0]
}

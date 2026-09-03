# hub-spoke-config — wires a BU spoke to the shared hub: bidirectional VNet peering, the
# hub firewall route table applied to the spoke's Databricks subnets (so egress leaves via
# the firewall), and the spoke subnet CIDRs added to the firewall IP group (so the firewall
# rules match spoke traffic). All always-on — the hub firewall + peering are the defining,
# non-optional feature of this topology — so nothing here is gated on a plan-time-unknown id.

module "peering" {
  source                    = "../_blocks/vnet-peering"
  left_vnet_name            = var.spoke_vnet_name
  left_vnet_id              = var.spoke_vnet_id
  left_resource_group_name  = var.spoke_resource_group_name
  right_vnet_name           = var.hub_vnet_name
  right_vnet_id             = var.hub_vnet_id
  right_resource_group_name = var.hub_resource_group_name
}

# Route the spoke's Databricks subnets through the hub firewall. Depends on the peering so
# the route table is only associated once the networks can reach each other.
resource "azurerm_subnet_route_table_association" "host" {
  subnet_id      = var.spoke_subnet_ids.host
  route_table_id = var.hub_route_table_id
  depends_on     = [module.peering]
}

resource "azurerm_subnet_route_table_association" "container" {
  subnet_id      = var.spoke_subnet_ids.container
  route_table_id = var.hub_route_table_id
  depends_on     = [module.peering]
}

# Add the spoke subnet CIDRs to the hub firewall IP group so the firewall's source-ip-group
# rules match this spoke's traffic.
resource "azurerm_ip_group_cidr" "host" {
  ip_group_id = var.hub_ipgroup_id
  cidr        = var.spoke_subnet_cidrs.host[0]
}

resource "azurerm_ip_group_cidr" "container" {
  ip_group_id = var.hub_ipgroup_id
  cidr        = var.spoke_subnet_cidrs.container[0]
}

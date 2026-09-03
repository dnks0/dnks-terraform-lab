# hub — shared central network for the hub-spoke topology. Owns its own resource group, the
# hub VNet with the AzureFirewallSubnet, an Azure Firewall (egress point for all spokes), an
# IP group (source for the firewall rules; spoke CIDRs are added by hub-spoke-config), and a
# route table whose default route points at the firewall (applied to spoke subnets by
# hub-spoke-config). Composed from generic _blocks; the Databricks-specific firewall rule
# collection group lives in firewall.tf. Derived values (region service-tag suffix) in locals.tf.

module "resource_group" {
  source   = "../_blocks/resource-group"
  name     = "${var.prefix}-rg"
  location = var.region
  tags     = var.tags
}

module "vnet" {
  source              = "../_blocks/vnet"
  name                = "${var.prefix}-vnet"
  location            = var.region
  resource_group_name = module.resource_group.name
  address_space       = var.vnet_cidrs
  tags                = var.tags
}

# Azure requires the firewall subnet to be named exactly "AzureFirewallSubnet".
module "firewall_subnet" {
  source               = "../_blocks/subnet"
  name                 = "AzureFirewallSubnet"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes     = var.firewall_subnets_cidr
}

module "firewall" {
  source              = "../_blocks/firewall"
  name                = "${var.prefix}-firewall"
  location            = var.region
  resource_group_name = module.resource_group.name
  firewall_subnet_id  = module.firewall_subnet.id
  tags                = var.tags
}

module "ip_group" {
  source              = "../_blocks/ip-group"
  name                = "${var.prefix}-firewall-ipg"
  location            = var.region
  resource_group_name = module.resource_group.name
}

module "route_table" {
  source              = "../_blocks/route-table"
  name                = "${var.prefix}-firewall-rtl"
  location            = var.region
  resource_group_name = module.resource_group.name
  tags                = var.tags
  routes = [{
    name                   = "${var.prefix}-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = module.firewall.private_ip_address
  }]
}

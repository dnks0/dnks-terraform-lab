# network — generic BU landing-zone network (no Databricks knowledge).
# Owns the virtual network and any generic extra subnets, deployed into the BU resource group
# (owned by the resource-group unit and supplied via var.resource_group_name). There is no NAT
# gateway: outbound egress in the hub-spoke topology routes through the hub Azure Firewall
# (via VNet peering + the route table applied by the hub-spoke-config unit). Databricks-specific
# subnets, NSG rules and private DNS zones live in the databricks/network module, which consumes
# this module's outputs.

module "vnet" {
  source              = "../_blocks/vnet"
  name                = "${var.prefix}-vnet"
  location            = var.region
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_cidrs
  tags                = var.tags
}

# Generic (non-Databricks) subnets for other workloads sharing this VNet.
module "extra_subnet" {
  source               = "../_blocks/subnet"
  for_each             = var.extra_subnets
  name                 = "${var.prefix}-${each.key}-snt"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.vnet.name
  address_prefixes     = each.value.address_prefixes
}

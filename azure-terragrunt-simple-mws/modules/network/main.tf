# network — generic BU landing-zone network (no Databricks knowledge).
# Owns the virtual network, an optional NAT gateway and any generic extra subnets,
# deployed into the BU resource group (owned by the resource-group unit and supplied
# via var.resource_group_name). Databricks-specific subnets, NSG rules and private DNS
# zones live in the databricks/network module, which consumes this module's outputs.

module "vnet" {
  source              = "../_blocks/vnet"
  name                = "${var.prefix}-vnet"
  location            = var.region
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_cidrs
  tags                = var.tags
}

module "nat" {
  source              = "../_blocks/nat"
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "${var.prefix}-nat"
  public_ip_name      = "${var.prefix}-nat-pip"
  location            = var.region
  resource_group_name = var.resource_group_name
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

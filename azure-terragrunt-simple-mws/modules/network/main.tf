# network — BU landing-zone network pattern module.
# Pure composition of _blocks: resource group, vnet, nsg (+Databricks egress rules),
# optional NAT gateway, the three Databricks subnets, any extra (non-Databricks) subnets,
# and the three Databricks private DNS zones. Consumed by the workspace/uc/storage units.

locals {
  # Databricks subnet delegation shared by container + host subnets.
  databricks_delegation = {
    name         = "databricks-subnet-delegation"
    service_name = "Microsoft.Databricks/workspaces"
    actions = [
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
    ]
  }

  # Databricks-required outbound NSG rules.
  databricks_nsg_rules = {
    AllowAAD = {
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureActiveDirectory"
    }
    AllowAzureFrontDoor = {
      priority                   = 201
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureFrontDoor.Frontend"
    }
  }

  nat_gateway_id = var.enable_nat_gateway ? module.nat[0].id : null

  # Private DNS zones this module owns, keyed by the logical name used downstream.
  dns_zones = {
    backend = "privatelink.azuredatabricks.net"
    dfs     = "privatelink.dfs.core.windows.net"
    blob    = "privatelink.blob.core.windows.net"
  }
}

module "resource_group" {
  source   = "../_blocks/resource_group"
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

module "nsg" {
  source              = "../_blocks/nsg"
  name                = "${var.prefix}-nsg"
  location            = var.region
  resource_group_name = module.resource_group.name
  security_rules      = local.databricks_nsg_rules
  tags                = var.tags
}

module "nat" {
  source              = "../_blocks/nat"
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "${var.prefix}-nat"
  public_ip_name      = "${var.prefix}-nat-pip"
  location            = var.region
  resource_group_name = module.resource_group.name
  tags                = var.tags
}

module "container_subnet" {
  source                    = "../_blocks/subnet"
  name                      = "${var.prefix}-container-snt"
  resource_group_name       = module.resource_group.name
  virtual_network_name      = module.vnet.name
  address_prefixes          = var.container_subnet_cidrs
  delegation                = local.databricks_delegation
  network_security_group_id = module.nsg.id
  nat_gateway_id            = local.nat_gateway_id
}

module "host_subnet" {
  source                    = "../_blocks/subnet"
  name                      = "${var.prefix}-host-snt"
  resource_group_name       = module.resource_group.name
  virtual_network_name      = module.vnet.name
  address_prefixes          = var.host_subnet_cidrs
  delegation                = local.databricks_delegation
  network_security_group_id = module.nsg.id
  nat_gateway_id            = local.nat_gateway_id
}

module "privatelink_subnet" {
  source               = "../_blocks/subnet"
  name                 = "${var.prefix}-privatelink-snt"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes     = var.privatelink_subnet_cidrs
}

module "extra_subnet" {
  source               = "../_blocks/subnet"
  for_each             = var.extra_subnets
  name                 = "${var.prefix}-${each.key}-snt"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes     = each.value.address_prefixes
}

module "dns_zone" {
  source              = "../_blocks/dns_zone"
  for_each            = local.dns_zones
  zone_name           = each.value
  link_name           = "${var.prefix}-${each.key}-vnl"
  resource_group_name = module.resource_group.name
  virtual_network_id  = module.vnet.id
  tags                = var.tags
}

# databricks_network — Databricks-specific connectivity layered on the generic BU network.
# Owns the NSG + Databricks egress rules, the delegated container/host subnets, the
# privatelink subnet, and the Databricks/storage private DNS zones. Consumes the generic
# vnet/RG/NAT from the network unit. Outputs network_configuration + dns_zone_ids for the
# workspace, storage and uc units.

locals {
  databricks_delegation = {
    name         = "databricks-subnet-delegation"
    service_name = "Microsoft.Databricks/workspaces"
    actions = [
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
    ]
  }

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

  nat_gateway_id = var.nat_gateway_id != "" ? var.nat_gateway_id : null

  # Only create the private DNS zones actually consumed by an enabled private endpoint:
  #  - backend zone: workspace backend PE (enable_backend_privatelink)
  #  - dfs/blob zones: workspace backend PE OR storage external-location PE
  storage_pl_enabled = var.enable_backend_privatelink || var.enable_external_location_privatelink
  dns_zones = merge(
    var.enable_backend_privatelink ? { backend = "privatelink.azuredatabricks.net" } : {},
    local.storage_pl_enabled ? {
      dfs  = "privatelink.dfs.core.windows.net"
      blob = "privatelink.blob.core.windows.net"
    } : {},
  )
}

module "nsg" {
  source              = "../_blocks/nsg"
  name                = "${var.prefix}-nsg"
  location            = var.region
  resource_group_name = var.resource_group_name
  security_rules      = local.databricks_nsg_rules
  tags                = var.tags
}

module "container_subnet" {
  source                    = "../_blocks/subnet"
  name                      = "${var.prefix}-container-snt"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.virtual_network_name
  address_prefixes          = var.container_subnet_cidrs
  delegation                = local.databricks_delegation
  network_security_group_id = module.nsg.id
  nat_gateway_id            = local.nat_gateway_id
}

module "host_subnet" {
  source                    = "../_blocks/subnet"
  name                      = "${var.prefix}-host-snt"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.virtual_network_name
  address_prefixes          = var.host_subnet_cidrs
  delegation                = local.databricks_delegation
  network_security_group_id = module.nsg.id
  nat_gateway_id            = local.nat_gateway_id
}

module "privatelink_subnet" {
  source               = "../_blocks/subnet"
  name                 = "${var.prefix}-privatelink-snt"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.privatelink_subnet_cidrs
}

module "dns_zone" {
  source              = "../_blocks/dns_zone"
  for_each            = local.dns_zones
  zone_name           = each.value
  link_name           = "${var.prefix}-${each.key}-vnl"
  resource_group_name = var.resource_group_name
  virtual_network_id  = var.virtual_network_id
  tags                = var.tags
}

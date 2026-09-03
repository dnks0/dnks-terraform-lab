# databricks/network — Databricks-specific connectivity layered on the generic BU network.
# Owns the NSG + Databricks egress rules, the delegated container/host subnets, the
# privatelink subnet, and the Databricks/storage private DNS zones. Consumes the generic
# vnet/RG from the network unit. Outputs network_configuration + dns_zone_ids for the
# workspace, storage and uc units, and spoke_subnet_ids/cidrs for the hub-spoke-config unit.
# There is no NAT association: spoke egress routes through the hub firewall (route table
# applied to these subnets by hub-spoke-config).
#
# Derived values (delegation, NSG rules, DNS zone set) live in locals.tf.

module "nsg" {
  source              = "../../_blocks/nsg"
  name                = "${var.prefix}-nsg"
  location            = var.region
  resource_group_name = var.resource_group_name
  security_rules      = local.databricks_nsg_rules
  tags                = var.tags
}

module "container_subnet" {
  source                           = "../../_blocks/subnet"
  name                             = "${var.prefix}-container-snt"
  resource_group_name              = var.resource_group_name
  virtual_network_name             = var.virtual_network_name
  address_prefixes                 = var.container_subnet_cidrs
  delegation                       = local.databricks_delegation
  associate_network_security_group = true
  network_security_group_id        = module.nsg.id
}

module "host_subnet" {
  source                           = "../../_blocks/subnet"
  name                             = "${var.prefix}-host-snt"
  resource_group_name              = var.resource_group_name
  virtual_network_name             = var.virtual_network_name
  address_prefixes                 = var.host_subnet_cidrs
  delegation                       = local.databricks_delegation
  associate_network_security_group = true
  network_security_group_id        = module.nsg.id
}

module "privatelink_subnet" {
  source               = "../../_blocks/subnet"
  name                 = "${var.prefix}-privatelink-snt"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.privatelink_subnet_cidrs
}

module "dns_zone" {
  source              = "../../_blocks/dns-zone"
  for_each            = local.dns_zones
  zone_name           = each.value
  link_name           = "${var.prefix}-${each.key}-vnl"
  resource_group_name = var.resource_group_name
  virtual_network_id  = var.virtual_network_id
  tags                = var.tags
}

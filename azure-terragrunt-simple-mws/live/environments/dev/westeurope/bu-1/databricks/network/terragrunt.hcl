include "root" {
  path    = find_in_parent_folders("root.hcl")
  expose  = true
}

terraform {
  # `//` marks the copy root so the pattern module can reference ../_blocks.
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//databricks_network"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

locals {
  flags = merge(include.root.locals.feature_flags, {})
}

dependency "network" {
  config_path = "../../network"

  mock_outputs = {
    resource_group_name = "mock-resource-group-name"
    vnet_id             = "mock-vnet-id"
    vnet_name           = "mock-vnet-name"
    nat_gateway_id      = "mock-nat-id"
    extra_subnet_ids    = {}
  }
}

inputs = {
  prefix                               = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  region                               = include.root.locals.region.name
  tags                                 = include.root.locals.default_tags
  resource_group_name                  = dependency.network.outputs.resource_group_name
  virtual_network_name                 = dependency.network.outputs.vnet_name
  virtual_network_id                   = dependency.network.outputs.vnet_id
  nat_gateway_id                       = dependency.network.outputs.nat_gateway_id
  container_subnet_cidrs               = ["10.0.0.0/22"]
  host_subnet_cidrs                    = ["10.0.4.0/22"]
  privatelink_subnet_cidrs             = ["10.0.28.0/26"]
  enable_backend_privatelink           = local.flags.enable_backend_privatelink
  enable_external_location_privatelink = local.flags.enable_external_location_privatelink
}

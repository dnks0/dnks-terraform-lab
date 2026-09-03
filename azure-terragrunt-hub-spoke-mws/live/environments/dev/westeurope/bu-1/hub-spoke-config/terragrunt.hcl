include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  # `//` marks the copy root so the pattern module can reference ../_blocks.
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//hub-spoke-config"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

dependency "hub" {
  config_path = "../../common/hub"

  mock_outputs = {
    azure_resource_group_name = "mock-resource-group-name"
    vnet_id                   = "mock-vnet-id"
    vnet_name                 = "mock-vnet-name"
    route_table_id            = "mock-route-table-id"
    ipgroup_id                = "mock-ipgroup-id"
  }
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    resource_group_name = "mock-resource-group-name"
    vnet_id             = "mock-vnet-id"
    vnet_name           = "mock-vnet-name"
    extra_subnet_ids    = {}
  }
}

dependency "databricks-network" {
  config_path = "../databricks/network"

  mock_outputs = {
    spoke_subnet_ids = {
      host      = "mock-host-subnet-id"
      container = "mock-container-subnet-id"
    }
    spoke_subnet_cidrs = {
      host      = ["10.173.4.0/22"]
      container = ["10.173.0.0/22"]
    }
  }
}

inputs = {
  prefix                    = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  region                    = include.root.locals.region.name
  tags                      = include.root.locals.default_tags
  hub_resource_group_name   = dependency.hub.outputs.azure_resource_group_name
  hub_vnet_id               = dependency.hub.outputs.vnet_id
  hub_vnet_name             = dependency.hub.outputs.vnet_name
  hub_route_table_id        = dependency.hub.outputs.route_table_id
  hub_ipgroup_id            = dependency.hub.outputs.ipgroup_id
  spoke_resource_group_name = dependency.network.outputs.resource_group_name
  spoke_vnet_id             = dependency.network.outputs.vnet_id
  spoke_vnet_name           = dependency.network.outputs.vnet_name
  spoke_subnet_ids          = dependency.databricks-network.outputs.spoke_subnet_ids
  spoke_subnet_cidrs        = dependency.databricks-network.outputs.spoke_subnet_cidrs
}

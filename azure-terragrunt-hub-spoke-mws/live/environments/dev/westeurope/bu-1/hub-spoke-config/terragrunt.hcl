include "root" {
  path    = find_in_parent_folders("root.hcl")
  expose  = true
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules/hub-spoke-config"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

dependency "hub" {
  config_path = "../../common/hub"

   mock_outputs = {
     azure_resource_group_name  = "mock-resource-group-name"
     vnet_id                    = "mock-vnet-id"
     vnet_name                  = "mock-vnet-name"
     route_table_id             = "mock-route-table-id"
     ipgroup_id                 = "mock-ipgroup-id"
   }
}

dependency "spoke-workspace" {
  config_path = "../spoke-workspace"

   mock_outputs = {
     workspace_id               = "mock-workspace-id"
     workspace_host             = "https://mock.workspace.host"
     workspace_name             = "mock-workspace-name"
     azure_resource_group_name  = "mock-resource-group-name"
     vnet_id                    = "mock-vnet-id"
     vnet_name                  = "mock-vnet-name"
     subnet_ids                 = {"host": "mock-host-subnet-ids", "container": "mock-container-subnet-ids", "privatelink": "mock-privatelink-subnet-ids"}
     subnet_cidrs               = {"host": "mock-host-subnet-cidr", "container": "mock-container-subnet-cidr", "privatelink": "mock-privatelink-subnet-cidr"}
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
  spoke_resource_group_name = dependency.spoke-workspace.outputs.azure_resource_group_name
  spoke_vnet_id             = dependency.spoke-workspace.outputs.vnet_id
  spoke_vnet_name           = dependency.spoke-workspace.outputs.vnet_name
  spoke_subnet_ids          = dependency.spoke-workspace.outputs.subnet_ids
  spoke_subnet_cidrs        = dependency.spoke-workspace.outputs.subnet_cidrs
}

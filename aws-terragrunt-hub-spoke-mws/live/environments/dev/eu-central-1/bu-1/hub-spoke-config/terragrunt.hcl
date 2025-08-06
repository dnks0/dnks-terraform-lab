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
     transit_gateway_id       = "mock-tgw-id"
     private_route_table_ids  = ["mock-private-route-table-ids"]
     public_route_table_ids   = ["mock-public-route-table-ids"]
   }
}

dependency "spoke-workspace" {
  config_path = "../spoke-workspace"

   mock_outputs = {
     workspace_id             = "mock-workspace-id"
     workspace_host           = "https://mock.workspace.host"
     workspace_name           = "mock-workspace-name"
     vpc_id                   = "mock-vpc-id"
     vpc_cidr                 = "mock-vpc-cidr"
     tgw_subnet_ids           = ["mock-tgw-subnet-ids"]
     private_route_table_ids  = ["mock-private-route-table-ids"]
   }
}

inputs = {
  prefix                              = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  region                              = include.root.locals.region.name
  tags                                = include.root.locals.default_tags
  hub_transit_gateway_id              = dependency.hub.outputs.transit_gateway_id
  hub_private_route_table_ids         = dependency.hub.outputs.private_route_table_ids
  hub_public_route_table_ids          = dependency.hub.outputs.public_route_table_ids
  spoke_vpc_id                        = dependency.spoke-workspace.outputs.vpc_id
  spoke_vpc_cidr                      = dependency.spoke-workspace.outputs.vpc_cidr
  spoke_tgw_subnet_ids                = dependency.spoke-workspace.outputs.tgw_subnet_ids
  spoke_private_route_table_ids       = dependency.spoke-workspace.outputs.private_route_table_ids
}

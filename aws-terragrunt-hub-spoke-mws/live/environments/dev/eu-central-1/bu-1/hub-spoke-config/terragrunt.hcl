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
    vpc_id                  = "vpc-mockhub00000000"
    vpc_cidr                = "10.10.0.0/18"
    transit_gateway_id      = "tgw-mock00000000000"
    private_route_table_ids = ["rtb-mockha", "rtb-mockhb", "rtb-mockhc"]
    public_route_table_ids  = ["rtb-mockhpub"]
  }
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    vpc_id           = "vpc-mock00000000000"
    vpc_cidr         = "10.173.0.0/18"
    tgw_subnet_ids   = ["subnet-mocka", "subnet-mockb", "subnet-mockc"]
    azs              = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
    extra_subnet_ids = {}
  }
}

dependency "databricks_network" {
  config_path = "../databricks/network"

  mock_outputs = {
    network_configuration = {
      vpc_id                  = "vpc-mock00000000000"
      private_subnet_ids      = ["subnet-mockd", "subnet-mocke", "subnet-mockf"]
      intra_subnet_ids        = ["subnet-mockg", "subnet-mockh", "subnet-mocki"]
      private_route_table_ids = ["rtb-mocka", "rtb-mockb", "rtb-mockc"]
    }
    workspace_security_group_id = "sg-mock00000000000"
    backend_rest_endpoint_id    = "vpce-mockrest0000000"
    backend_relay_endpoint_id   = "vpce-mockrelay000000"
  }
}

inputs = {
  prefix                        = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  tags                          = include.root.locals.default_tags
  hub_transit_gateway_id        = dependency.hub.outputs.transit_gateway_id
  hub_private_route_table_ids   = dependency.hub.outputs.private_route_table_ids
  hub_public_route_table_ids    = dependency.hub.outputs.public_route_table_ids
  spoke_vpc_id                  = dependency.network.outputs.vpc_id
  spoke_vpc_cidr                = dependency.network.outputs.vpc_cidr
  spoke_tgw_subnet_ids          = dependency.network.outputs.tgw_subnet_ids
  spoke_private_route_table_ids = dependency.databricks_network.outputs.network_configuration.private_route_table_ids
}

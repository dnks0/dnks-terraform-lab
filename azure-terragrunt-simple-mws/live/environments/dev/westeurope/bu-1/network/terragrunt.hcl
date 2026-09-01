include "root" {
  path    = find_in_parent_folders("root.hcl")
  expose  = true
}

terraform {
  # `//` marks the copy root so the pattern module can reference ../_blocks.
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//network"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

locals {
  flags = merge(include.root.locals.feature_flags, {})
}

dependency "resource-group" {
  config_path = "../resource-group"

  mock_outputs = {
    resource_group_name     = "mock-resource-group-name"
    resource_group_location = "westeurope"
  }
}

inputs = {
  prefix              = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  region              = include.root.locals.region.name
  tags                = include.root.locals.default_tags
  resource_group_name = dependency.resource-group.outputs.resource_group_name
  vnet_cidrs          = ["10.0.0.0/18"]
  enable_nat_gateway  = local.flags.enable_nat_gateway

  # extra_subnets = { app-tier = { address_prefixes = ["10.0.8.0/22"] } }
}

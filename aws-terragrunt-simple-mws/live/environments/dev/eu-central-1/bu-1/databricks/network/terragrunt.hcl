include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  # `//` marks the copy root so the pattern module can reference ../../_blocks.
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//databricks/network"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

locals {
  flags = merge(include.root.locals.feature_flags, {})
}

dependency "network" {
  config_path = "../../network"

  mock_outputs = {
    vpc_id            = "vpc-mock00000000000"
    nat_gateway_ids   = ["nat-mocka", "nat-mockb", "nat-mockc"]
    azs               = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
    public_subnet_ids = ["subnet-mocka", "subnet-mockb", "subnet-mockc"]
    vpc_cidr          = "10.0.0.0/18"
    igw_id            = "igw-mock00000000000"
    extra_subnet_ids  = {}
  }
}

inputs = {
  prefix                   = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  region                   = include.root.locals.region.name
  tags                     = include.root.locals.default_tags
  vpc_id                   = dependency.network.outputs.vpc_id
  nat_gateway_ids          = dependency.network.outputs.nat_gateway_ids
  azs                      = dependency.network.outputs.azs
  private_subnets_cidr     = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
  privatelink_subnets_cidr = ["10.0.28.0/26", "10.0.28.64/26", "10.0.28.128/26"]
  sg_egress_ports          = [443, 2443, 3306, 6666, 8443, 8444, 8445, 8446, 8447, 8448, 8449, 8450, 8451]

  enable_classic_privatelink = local.flags.enable_classic_privatelink
  enable_outbound_nat        = local.flags.enable_outbound_nat
}

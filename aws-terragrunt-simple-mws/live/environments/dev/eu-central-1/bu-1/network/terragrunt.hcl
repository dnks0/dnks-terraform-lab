include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
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

inputs = {
  prefix              = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  tags                = include.root.locals.default_tags
  vpc_cidr            = "10.0.0.0/18"
  public_subnets_cidr = ["10.0.29.0/26", "10.0.29.64/26", "10.0.29.128/26"]
  enable_outbound_nat = local.flags.enable_outbound_nat

  # extra_subnets = { app-tier = { cidr_block = "10.0.8.0/22", availability_zone = "eu-central-1a" } }
}

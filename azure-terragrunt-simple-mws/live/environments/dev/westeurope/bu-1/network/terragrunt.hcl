include "root" {
  path    = find_in_parent_folders("root.hcl")
  expose  = true
}

terraform {
  # `//` marks the copy root: Terragrunt copies the whole `modules` tree into its cache
  # (so the pattern module can reference ../_blocks) and operates in the `network` subdir.
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//network"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

locals {
  # Per-unit feature-flag overrides layer on top of the resolved cascade.
  flags = merge(include.root.locals.feature_flags, {})
}

inputs = {
  prefix                   = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  region                   = include.root.locals.region.name
  tags                     = include.root.locals.default_tags
  vnet_cidrs               = ["10.0.0.0/18"]
  container_subnet_cidrs   = ["10.0.0.0/22"]
  host_subnet_cidrs        = ["10.0.4.0/22"]
  privatelink_subnet_cidrs = ["10.0.28.0/26"]
  enable_nat_gateway       = local.flags.enable_nat_gateway

  # extra_subnets = { app-tier = { address_prefixes = ["10.0.8.0/22"] } }
}

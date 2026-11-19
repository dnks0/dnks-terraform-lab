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

inputs = {
  prefix           = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  tags             = include.root.locals.default_tags
  vpc_cidr         = "10.173.0.0/18"
  tgw_subnets_cidr = ["10.173.12.64/28", "10.173.12.80/28", "10.173.12.96/28"]

  # extra_subnets = { app-tier = { cidr_block = "10.173.16.0/22", availability_zone = "eu-central-1a" } }
}

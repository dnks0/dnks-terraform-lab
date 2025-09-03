include "root" {
  path    = find_in_parent_folders("root.hcl")
  expose  = true
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules/hub"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

inputs = {
  prefix                          = "${include.root.locals.prefix}-dbx-hub"
  region                          = include.root.locals.region.name
  tags                            = include.root.locals.default_tags
  vnet_cidrs                      = ["10.10.0.0/18"]
  firewall_subnets_cidr           = ["10.10.0.0/26"]
}

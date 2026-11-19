include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  # `//` marks the copy root so the pattern module can reference ../_blocks.
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//hub"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

inputs = {
  prefix               = "${include.root.locals.prefix}-dbx-hub"
  tags                 = include.root.locals.default_tags
  vpc_cidr             = "10.10.0.0/18"
  private_subnets_cidr = ["10.10.0.0/26", "10.10.0.64/26", "10.10.0.128/26"]
  public_subnets_cidr  = ["10.10.1.0/26", "10.10.1.64/26", "10.10.1.128/26"]
}

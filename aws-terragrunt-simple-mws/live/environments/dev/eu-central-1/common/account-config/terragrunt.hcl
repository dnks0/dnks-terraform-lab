include "root" {
  path    = find_in_parent_folders("root.hcl")
  expose  = true
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules/account-config"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

inputs = {
  prefix                          = "${include.root.locals.prefix}-dbx"
  region                          = include.root.locals.region.name
  tags                            = include.root.locals.default_tags
  databricks_account_id           = include.root.locals.databricks_account_id
  databricks_account_client_id    = include.root.locals.databricks_account_client_id
  databricks_account_admins       = []  # add account-admins if required! default will use the current service-principal used for deployments
  enable_serverless_connectivity  = false
}

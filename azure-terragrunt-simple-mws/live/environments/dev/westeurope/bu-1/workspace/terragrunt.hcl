include "root" {
  path    = find_in_parent_folders("root.hcl")
  expose  = true
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules/workspace"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

dependency "account-config" {
  config_path = "../../common/account-config"

   mock_outputs = {
     metastore_id                           = "mock-metastore-id"
     account_admin_group_id                 = 00000
     account_admin_group_name               = "mock-group-name"
     network_connectivity_configuration_id  = "mock-ncc-id"
     network_policy_id                      = "mock-np-id"
   }
}

inputs = {
  prefix                            = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  region                            = include.root.locals.region.name
  tags                              = include.root.locals.default_tags
  databricks_account_id             = include.root.locals.databricks_account_id
  databricks_metastore_ids          = [dependency.account-config.outputs.metastore_id]
  databricks_account_admin_group_id = dependency.account-config.outputs.account_admin_group_id
  vnet_cidrs                        = ["10.0.0.0/18"]
  container_subnet_cidrs            = ["10.0.0.0/22"]
  host_subnet_cidrs                 = ["10.0.4.0/22"]
  privatelink_subnet_cidrs          = ["10.0.28.0/26"]
  ncc_id                            = dependency.account-config.outputs.network_connectivity_configuration_id
  np_id                             = dependency.account-config.outputs.network_policy_id
}

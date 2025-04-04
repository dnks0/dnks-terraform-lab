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
     metastore_id             = "mock-metastore-id"
     metastore_bucket_arn     = "mock-bucket-arn"
     account_admin_group_id   = 00000
     account_admin_group_name = "mock-group-name"
   }
}

inputs = {
  prefix                            = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  region                            = include.root.locals.region.name
  tags                              = include.root.locals.default_tags
  databricks_account_id             = include.root.locals.databricks_account_id
  databricks_metastore_ids          = [dependency.account-config.outputs.metastore_id]
  databricks_metastore_bucket_arn   = dependency.account-config.outputs.metastore_bucket_arn
  databricks_account_admin_group_id = dependency.account-config.outputs.account_admin_group_id
  vpc_cidr                          = "10.0.0.0/18"
  private_subnets_cidr              = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
  public_subnets_cidr               = ["10.0.29.0/26", "10.0.29.64/26", "10.0.29.128/26"]
  privatelink_subnets_cidr          = ["10.0.28.0/26", "10.0.28.64/26", "10.0.28.128/26"]
  sg_egress_ports                   = [443, 3306, 6666, 8443, 8444, 8445, 8446, 8447, 8448, 8449, 8450, 8451]
}

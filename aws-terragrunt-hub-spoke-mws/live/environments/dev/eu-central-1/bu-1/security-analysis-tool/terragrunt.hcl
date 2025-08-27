include "root" {
  path    = find_in_parent_folders("root.hcl")
  expose  = true
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules/security-analysis-tool"
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

dependency "spoke-workspace" {
  config_path = "../spoke-workspace"

   mock_outputs = {
     workspace_id   = "mock-workspace-id"
     workspace_host = "https://mock.workspace.host"
     workspace_name = "mock-workspace-name"
   }
}

dependency "workspace-config" {
  config_path = "../workspace-config"

  mock_outputs = {
    catalog           = "mock-catalog-name"
    sql_warehouse_id  = "mock-sql-warehouse-id"
  }
}

inputs = {
  databricks_account_id             = include.root.locals.databricks_account_id
  databricks_account_client_id      = include.root.locals.databricks_account_client_id
  databricks_account_client_secret  = include.root.locals.databricks_account_client_secret
  workspace_host                    = dependency.spoke-workspace.outputs.workspace_host
  sql_warehouse_id                  = dependency.workspace-config.outputs.sql_warehouse_id
  catalog                           = dependency.workspace-config.outputs.catalog
  admin_group                       = dependency.account-config.outputs.account_admin_group_name
  serverless                        = true
  use_sp_auth                       = true
  proxies                           = {}
  secret_scope                      = "sat_scope"
}

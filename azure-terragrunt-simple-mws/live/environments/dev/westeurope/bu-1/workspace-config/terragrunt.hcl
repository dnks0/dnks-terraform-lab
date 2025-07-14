include "root" {
  path    = find_in_parent_folders("root.hcl")
  expose  = true
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules/workspace-config"
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

dependency "workspace" {
  config_path = "../workspace"

   mock_outputs = {
     workspace_id               = "mock-workspace-id"
     workspace_host             = "https://mock.workspace.host"
     workspace_name             = "mock-workspace-name"
     azure_resource_group_name  = "mock-resource-group-name"
   }
}

inputs = {
  prefix                    = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  region                    = include.root.locals.region.name
  tags                      = include.root.locals.default_tags
  business_unit             = include.root.locals.business_unit.name
  admin_group               = dependency.account-config.outputs.account_admin_group_name
  workspace_host            = dependency.workspace.outputs.workspace_host
  workspace_name            = dependency.workspace.outputs.workspace_name
  system_schemas            = ["access", "billing", "compute", "lakeflow", "marketplace", "storage", "query", "serving"]
  azure_resource_group_name = dependency.workspace.outputs.azure_resource_group_name
}

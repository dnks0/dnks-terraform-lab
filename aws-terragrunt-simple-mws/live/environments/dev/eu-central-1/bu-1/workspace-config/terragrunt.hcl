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
     metastore_id             = "mock-metastore-id"
     metastore_bucket_arn     = "mock-bucket-arn"
     account_admin_group_id   = 00000
     account_admin_group_name = "mock-group-name"
   }
}

dependency "workspace" {
  config_path = "../workspace"

   mock_outputs = {
     workspace_id  = "mock-workspace-id"
     workspace_host = "https://mock.workspace.host"
   }
}

inputs = {
  business_unit   = include.root.locals.business_unit.name
  admin_group     = dependency.account-config.outputs.account_admin_group_name
  workspace_host  = dependency.workspace.outputs.workspace_host
  system_schemas  = ["access", "billing", "compute", "lakeflow", "marketplace", "storage", "query", "serving"]
}

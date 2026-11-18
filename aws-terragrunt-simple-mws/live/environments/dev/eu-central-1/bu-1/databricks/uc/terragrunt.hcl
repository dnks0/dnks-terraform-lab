include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  # `//` marks the copy root so the pattern module can reference ../../_blocks.
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//databricks/uc"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

dependency "account-config" {
  config_path = "../../../common/account-config"

  mock_outputs = {
    metastore_id             = "mock-metastore-id"
    account_admin_group_id   = 00000
    account_admin_group_name = "mock-group-name"
  }
}

dependency "workspace" {
  config_path = "../workspace"

  mock_outputs = {
    workspace_id   = "mock-workspace-id"
    workspace_host = "https://mock.workspace.host"
    workspace_name = "mock-workspace-name"
  }
}

dependency "storage" {
  config_path = "../storage"

  mock_outputs = {
    bucket_name = "mock-bucket"
    bucket_arn  = "arn:aws:s3:::mock-bucket"
    bucket_id   = "mock-bucket"
  }
}

inputs = {
  prefix         = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  tags           = include.root.locals.default_tags
  business_unit  = include.root.locals.business_unit.name
  admin_group    = dependency.account-config.outputs.account_admin_group_name
  workspace_host = dependency.workspace.outputs.workspace_host
  workspace_name = dependency.workspace.outputs.workspace_name
  bucket_name    = dependency.storage.outputs.bucket_name
}

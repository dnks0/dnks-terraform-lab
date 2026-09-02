include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules/databricks/workspace-config"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

locals {
  flags = merge(include.root.locals.feature_flags, {})
}

dependency "workspace" {
  config_path = "../workspace"

  mock_outputs = {
    workspace_id              = "mock-workspace-id"
    workspace_host            = "https://mock.workspace.host"
    workspace_name            = "mock-workspace-name"
    azure_resource_group_name = "mock-resource-group-name"
  }
}

inputs = {
  business_unit             = include.root.locals.business_unit.name
  workspace_host            = dependency.workspace.outputs.workspace_host
  enable_default_compute    = local.flags.enable_default_compute
  disable_starter_warehouse = local.flags.disable_starter_warehouse
}

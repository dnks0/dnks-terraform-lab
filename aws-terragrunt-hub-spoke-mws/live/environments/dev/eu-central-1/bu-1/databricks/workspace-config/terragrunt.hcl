include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//databricks/workspace-config"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

locals {
  flags = merge(include.root.locals.feature_flags, {})
}

# Ordering only (no outputs consumed): the spoke has no egress until hub-spoke-config has added
# 0.0.0.0/0 → Transit Gateway, so default compute must not start before it.
dependencies {
  paths = ["../../hub-spoke-config"]
}

dependency "workspace" {
  config_path = "../workspace"

  mock_outputs = {
    workspace_id   = "mock-workspace-id"
    workspace_host = "https://mock.workspace.host"
    workspace_name = "mock-workspace-name"
  }
}

inputs = {
  business_unit          = include.root.locals.business_unit.name
  workspace_host         = dependency.workspace.outputs.workspace_host
  enable_default_compute = local.flags.enable_default_compute
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  # `//` marks the copy root so the pattern module can reference ../../_blocks.
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//databricks/workspace"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

locals {
  flags = merge(include.root.locals.feature_flags, {})
}

dependency "account-config" {
  config_path = "../../../common/account-config"

  mock_outputs = {
    metastore_id                          = "mock-metastore-id"
    account_admin_group_id                = 00000
    account_admin_group_name              = "mock-group-name"
    network_connectivity_configuration_id = "mock-ncc-id"
    network_policy_id                     = "mock-np-id"
  }
}

dependency "databricks_network" {
  config_path = "../network"

  mock_outputs = {
    network_configuration = {
      vpc_id                  = "vpc-mock00000000000"
      private_subnet_ids      = ["subnet-mocka", "subnet-mockb", "subnet-mockc"]
      intra_subnet_ids        = ["subnet-mockd", "subnet-mocke", "subnet-mockf"]
      private_route_table_ids = ["rtb-mocka", "rtb-mockb", "rtb-mockc"]
    }
    workspace_security_group_id = "sg-mock00000000000"
    backend_rest_endpoint_id    = "vpce-mockrest0000000"
    backend_relay_endpoint_id   = "vpce-mockrelay000000"
  }
}

inputs = {
  prefix                = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  region                = include.root.locals.region.name
  tags                  = include.root.locals.default_tags
  databricks_account_id = include.root.locals.databricks_account_id

  databricks_metastore_ids          = [dependency.account-config.outputs.metastore_id]
  databricks_account_admin_group_id = dependency.account-config.outputs.account_admin_group_id

  network_configuration       = dependency.databricks_network.outputs.network_configuration
  workspace_security_group_id = dependency.databricks_network.outputs.workspace_security_group_id
  backend_rest_endpoint_id    = dependency.databricks_network.outputs.backend_rest_endpoint_id
  backend_relay_endpoint_id   = dependency.databricks_network.outputs.backend_relay_endpoint_id

  ncc_id = dependency.account-config.outputs.network_connectivity_configuration_id
  np_id  = dependency.account-config.outputs.network_policy_id

  enable_classic_privatelink = local.flags.enable_classic_privatelink
}

include "root" {
  path    = find_in_parent_folders("root.hcl")
  expose  = true
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules/workspace"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

locals {
  # Per-unit feature-flag overrides layer on top of the resolved cascade.
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
    resource_group_name = "mock-resource-group-name"
    network_configuration = {
      virtual_network_id                  = "mock-vnet-id"
      host_subnet_name                    = "mock-host-snt"
      container_subnet_name               = "mock-container-snt"
      privatelink_subnet_id               = "mock-privatelink-snt-id"
      host_subnet_nsg_association_id      = "mock-host-nsg-assoc-id"
      container_subnet_nsg_association_id = "mock-container-nsg-assoc-id"
    }
    dns_zone_ids = {
      backend = "mock-backend-zone-id"
      dfs     = "mock-dfs-zone-id"
      blob    = "mock-blob-zone-id"
    }
  }
}

inputs = {
  prefix                            = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  region                            = include.root.locals.region.name
  tags                              = include.root.locals.default_tags
  databricks_account_id             = include.root.locals.databricks_account_id
  databricks_metastore_ids          = [dependency.account-config.outputs.metastore_id]
  databricks_account_admin_group_id = dependency.account-config.outputs.account_admin_group_id
  resource_group_name               = dependency.databricks_network.outputs.resource_group_name
  network_configuration             = dependency.databricks_network.outputs.network_configuration
  dns_zone_ids                      = dependency.databricks_network.outputs.dns_zone_ids
  enable_backend_privatelink        = local.flags.enable_backend_privatelink
  ncc_id                            = dependency.account-config.outputs.network_connectivity_configuration_id
  np_id                             = dependency.account-config.outputs.network_policy_id
}

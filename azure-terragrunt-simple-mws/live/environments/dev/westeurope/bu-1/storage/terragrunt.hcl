include "root" {
  path    = find_in_parent_folders("root.hcl")
  expose  = true
}

terraform {
  # `//` marks the copy root so the pattern module can reference ../_blocks.
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../modules//storage"
  # Deploy versions via git
  # source = "git::git@github.com:path/to/repo.git//path/to/module?ref=v0.0.1"
}

locals {
  flags = merge(include.root.locals.feature_flags, {})
}

dependency "network" {
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
    extra_subnet_ids = {}
    nat_gateway_id   = "mock-nat-id"
  }
}

inputs = {
  prefix                               = "${include.root.locals.prefix}-${include.root.locals.environment.name}-${include.root.locals.business_unit.name}-dbx"
  region                               = include.root.locals.region.name
  tags                                 = include.root.locals.default_tags
  resource_group_name                  = dependency.network.outputs.resource_group_name
  privatelink_subnet_id                = dependency.network.outputs.network_configuration.privatelink_subnet_id
  dns_zone_ids = {
    dfs  = dependency.network.outputs.dns_zone_ids.dfs
    blob = dependency.network.outputs.dns_zone_ids.blob
  }
  enable_external_location_privatelink = local.flags.enable_external_location_privatelink
}

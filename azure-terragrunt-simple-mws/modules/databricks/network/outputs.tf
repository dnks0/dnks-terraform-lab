# Pass-through of the BU resource group so consumers (workspace, storage) can depend on
# this single unit rather than also depending on the generic network unit.
output "resource_group_name" {
  description = "Name of the BU resource group (passed through from the network unit)"
  value       = var.resource_group_name
}

# Bundled network configuration consumed by the workspace unit (BYO-network ready).
output "network_configuration" {
  description = "Network wiring for the Databricks workspace"
  value = {
    virtual_network_id                  = var.virtual_network_id
    host_subnet_name                    = module.host_subnet.name
    container_subnet_name               = module.container_subnet.name
    privatelink_subnet_id               = module.privatelink_subnet.id
    host_subnet_nsg_association_id      = module.host_subnet.network_security_group_association_id
    container_subnet_nsg_association_id = module.container_subnet.network_security_group_association_id
  }
}

# Private DNS zone IDs, keyed by logical name. Keys are always present (stable shape);
# a value is "" when that zone is not created because its Private Link is disabled.
output "dns_zone_ids" {
  description = "Private DNS zone IDs { classic, dfs, blob }; \"\" when the zone is disabled"
  value = {
    classic = try(module.dns_zone["classic"].id, "")
    dfs     = try(module.dns_zone["dfs"].id, "")
    blob    = try(module.dns_zone["blob"].id, "")
  }
}

# NSP profile ID for the storage unit to associate its storage account with.
# Empty string when serverless connectivity is disabled — stable output shape.
output "nsp_profile_id" {
  description = "Network Security Perimeter profile ID; \"\" when serverless connectivity is disabled"
  value       = var.enable_serverless_connectivity ? azurerm_network_security_perimeter_profile.this[0].id : ""
}

output "resource_group_name" {
  description = "Name of the BU resource group"
  value       = module.resource_group.name
}

# Bundled network configuration consumed by the workspace unit (and reusable for BYO-network:
# a future variant can supply this object from an existing network instead of this module).
output "network_configuration" {
  description = "Network wiring for the Databricks workspace"
  value = {
    virtual_network_id                    = module.vnet.id
    host_subnet_name                      = module.host_subnet.name
    container_subnet_name                 = module.container_subnet.name
    privatelink_subnet_id                 = module.privatelink_subnet.id
    host_subnet_nsg_association_id        = module.host_subnet.network_security_group_association_id
    container_subnet_nsg_association_id   = module.container_subnet.network_security_group_association_id
  }
}

# Private DNS zone IDs, keyed by logical name. Always present (zones are always created),
# so the shape is stable regardless of feature flags. Consumed by backend PEs (workspace)
# and external-location PEs (uc/storage).
output "dns_zone_ids" {
  description = "Private DNS zone IDs { backend, dfs, blob }"
  value = {
    backend = module.dns_zone["backend"].id
    dfs     = module.dns_zone["dfs"].id
    blob    = module.dns_zone["blob"].id
  }
}

# Extra (non-Databricks) subnet IDs, for other workloads sharing this VNet.
output "extra_subnet_ids" {
  description = "IDs of extra subnets, keyed by their config key"
  value       = { for k, m in module.extra_subnet : k => m.id }
}

# Empty string when NAT is disabled — stable output shape.
output "nat_gateway_id" {
  description = "NAT gateway ID, or empty string when disabled"
  value       = var.enable_nat_gateway ? module.nat[0].id : ""
}

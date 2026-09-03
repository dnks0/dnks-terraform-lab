# Pass-through: the RG is owned by the resource-group unit and supplied as an input.
# Re-emitted so downstream units (databricks/network -> storage/workspace) keep their chain.
output "resource_group_name" {
  description = "Name of the BU resource group"
  value       = var.resource_group_name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.vnet.name
}

output "extra_subnet_ids" {
  description = "IDs of generic extra subnets, keyed by their config key"
  value       = { for k, m in module.extra_subnet : k => m.id }
}

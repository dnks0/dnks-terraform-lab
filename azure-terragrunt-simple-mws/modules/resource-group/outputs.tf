output "resource_group_name" {
  description = "Name of the BU resource group"
  value       = module.resource_group.name
}

output "resource_group_location" {
  description = "Location of the BU resource group"
  value       = module.resource_group.location
}

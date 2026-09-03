output "azure_resource_group_name" {
  value = module.resource_group.name
}

output "vnet_id" {
  value = module.vnet.id
}

output "vnet_name" {
  value = module.vnet.name
}

output "route_table_id" {
  value = module.route_table.id
}

output "ipgroup_id" {
  value = module.ip_group.id
}

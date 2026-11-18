output "vpc_id" {
  description = "ID of the hub VPC"
  value       = module.vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the hub VPC"
  value       = module.vpc.cidr_block
}

output "transit_gateway_id" {
  description = "ID of the hub Transit Gateway (spokes attach to it in hub-spoke-config)"
  value       = module.transit_gateway.id
}

output "private_route_table_ids" {
  description = "Per-AZ private route table IDs (ordered by AZ); hub-spoke-config adds spoke return routes"
  value       = module.private_rt[*].id
}

output "public_route_table_ids" {
  description = "Public route table IDs (one shared table); hub-spoke-config adds spoke return routes"
  value       = [module.public_rt.id]
}

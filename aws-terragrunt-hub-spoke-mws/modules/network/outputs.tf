output "vpc_id" {
  description = "ID of the spoke VPC"
  value       = module.vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the spoke VPC (hub-spoke-config routes it back through the TGW)"
  value       = module.vpc.cidr_block
}

output "tgw_subnet_ids" {
  description = "IDs of the Transit Gateway attachment subnets (ordered by AZ)"
  value       = module.tgw_subnet[*].id
}

output "azs" {
  description = "Availability zones used for the subnets (ordered); consumed by databricks/network"
  value       = local.azs
}

output "extra_subnet_ids" {
  description = "IDs of generic extra subnets, keyed by their config key"
  value       = { for k, m in module.extra_subnet : k => m.id }
}

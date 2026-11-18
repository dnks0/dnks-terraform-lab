output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.cidr_block
}

output "igw_id" {
  description = "ID of the internet gateway"
  value       = module.vpc.igw_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (ordered by AZ)"
  value       = module.public_subnet[*].id
}

# Per-AZ NAT gateway IDs, ordered by AZ. Empty list when NAT is disabled — stable output shape.
# databricks/network's per-AZ private route tables route to these by index.
output "nat_gateway_ids" {
  description = "Per-AZ NAT gateway IDs (ordered by AZ); empty list when disabled"
  value       = module.nat[*].id
}

output "azs" {
  description = "Availability zones used for the subnets (ordered); consumed by databricks/network"
  value       = local.azs
}

output "extra_subnet_ids" {
  description = "IDs of generic extra subnets, keyed by their config key"
  value       = { for k, m in module.extra_subnet : k => m.id }
}

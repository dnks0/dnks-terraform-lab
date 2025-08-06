output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.this.id
}

output "private_route_table_ids" {
  value = module.vpc[0].private_route_table_ids
}

output "public_route_table_ids" {
  value = module.vpc[0].public_route_table_ids
}

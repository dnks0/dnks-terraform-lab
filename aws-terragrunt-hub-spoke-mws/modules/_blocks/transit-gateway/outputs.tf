output "id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.id
}

output "association_default_route_table_id" {
  description = "ID of the Transit Gateway's default (association) route table"
  value       = aws_ec2_transit_gateway.this.association_default_route_table_id
}

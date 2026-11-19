output "id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

# Empty string when no internet gateway is created — stable output shape.
output "igw_id" {
  description = "ID of the internet gateway, or empty string when not created"
  value       = one(aws_internet_gateway.this[*].id) == null ? "" : one(aws_internet_gateway.this[*].id)
}

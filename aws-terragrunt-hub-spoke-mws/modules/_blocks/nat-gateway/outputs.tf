output "id" {
  description = "ID of the NAT gateway"
  value       = aws_nat_gateway.this.id
}

output "public_ip" {
  description = "Elastic IP address of the NAT gateway"
  value       = aws_eip.this.public_ip
}

output "eip_id" {
  description = "Allocation ID of the Elastic IP"
  value       = aws_eip.this.id
}

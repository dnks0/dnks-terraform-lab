output "id" {
  description = "ID of the subnet"
  value       = aws_subnet.this.id
}

output "arn" {
  description = "ARN of the subnet"
  value       = aws_subnet.this.arn
}

output "cidr_block" {
  description = "CIDR block of the subnet"
  value       = aws_subnet.this.cidr_block
}

output "availability_zone" {
  description = "Availability zone of the subnet"
  value       = aws_subnet.this.availability_zone
}

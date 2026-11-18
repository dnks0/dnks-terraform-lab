output "id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}

output "arn" {
  description = "ARN of the security group"
  value       = aws_security_group.this.arn
}

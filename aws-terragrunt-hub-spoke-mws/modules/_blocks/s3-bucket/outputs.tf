output "id" {
  description = "ID (name) of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

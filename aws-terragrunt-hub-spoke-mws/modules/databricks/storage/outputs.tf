output "bucket_name" {
  description = "Name of the UC data bucket"
  value       = module.bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the UC data bucket"
  value       = module.bucket.arn
}

output "bucket_id" {
  description = "ID of the UC data bucket"
  value       = module.bucket.id
}

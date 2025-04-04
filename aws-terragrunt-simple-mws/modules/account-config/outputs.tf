output "metastore_id" {
  value = databricks_metastore.this.id
}

output "metastore_bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "account_admin_group_id" {
  value = databricks_group.admin_group.id
}

output "account_admin_group_name" {
  value = databricks_group.admin_group.display_name
}

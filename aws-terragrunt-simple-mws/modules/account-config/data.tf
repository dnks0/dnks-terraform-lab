data "databricks_service_principal" "this" {
  provider        = databricks.mws
  application_id  = var.databricks_account_client_id
}

data "databricks_user" "account-admins" {
  provider  = databricks.mws
  for_each  = toset(concat(local.databricks_account_admins))
  user_name = each.key
}

data "databricks_aws_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.bucket
}

data "aws_caller_identity" "current" {}

data "databricks_node_type" "smallest" {
  provider  = databricks.workspace
  local_disk = true
}

data "databricks_spark_version" "latest-lts" {
  provider  = databricks.workspace
  long_term_support = true
}

data "databricks_aws_unity_catalog_policy" "this" {
  aws_account_id = data.aws_caller_identity.current.account_id
  bucket_name    = aws_s3_bucket.this.bucket
  role_name      = "${var.prefix}-uc-role"
}

data "databricks_aws_unity_catalog_assume_role_policy" "this" {
  aws_account_id = data.aws_caller_identity.current.account_id
  role_name      = "${var.prefix}-uc-role"
  external_id    = databricks_storage_credential.this.aws_iam_role[0].external_id
}

data "aws_caller_identity" "current" {}

# These databricks data sources are local policy generators (no API call); run on the mws
# provider that root.hcl injects into the unit.
data "databricks_aws_assume_role_policy" "this" {
  provider    = databricks.mws
  external_id = var.databricks_account_id
}

data "databricks_aws_crossaccount_policy" "this" {
  provider = databricks.mws
}

data "databricks_aws_bucket_policy" "this" {
  provider                 = databricks.mws
  databricks_e2_account_id = var.databricks_account_id
  bucket                   = local.root_bucket_name
}

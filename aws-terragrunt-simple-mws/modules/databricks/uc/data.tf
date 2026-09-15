data "aws_caller_identity" "current" {}

# Local policy generators (no API call); run on the mws provider root.hcl injects into the unit.
# role_name is the deterministic UC role name (the role itself is created by module.uc_role);
# referencing the string avoids a cycle with the role resource.
data "databricks_aws_unity_catalog_policy" "this" {
  provider       = databricks.mws
  aws_account_id = data.aws_caller_identity.current.account_id
  bucket_name    = var.bucket_name
  role_name      = "${var.prefix}-uc-role"
}

data "databricks_aws_unity_catalog_assume_role_policy" "this" {
  provider       = databricks.mws
  aws_account_id = data.aws_caller_identity.current.account_id
  role_name      = "${var.prefix}-uc-role"
  external_id    = databricks_storage_credential.this.aws_iam_role[0].external_id
}

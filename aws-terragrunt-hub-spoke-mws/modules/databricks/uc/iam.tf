# UC IAM role + managed policy. Trust policy is built from the storage credential's external_id
# (see data.tf), so this role and the credential are co-located in this state.
module "uc_role" {
  source              = "../../_blocks/iam-role"
  name                = "${var.prefix}-uc-role"
  assume_role_policy  = data.databricks_aws_unity_catalog_assume_role_policy.this.json
  managed_policy_name = "${var.prefix}-uc-policy"
  managed_policy      = data.databricks_aws_unity_catalog_policy.this.json
  tags                = var.tags
}

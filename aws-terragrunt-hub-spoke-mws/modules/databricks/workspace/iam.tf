# Cross-account IAM role Databricks assumes to manage the workspace's data plane.
module "crossaccount_role" {
  source             = "../../_blocks/iam-role"
  name               = "${var.prefix}-crossaccount-role"
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json
  inline_policy_name = "${var.prefix}-crossaccount-policy"
  inline_policy      = data.databricks_aws_crossaccount_policy.this.json
  tags               = var.tags
}

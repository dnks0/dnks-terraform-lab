resource "databricks_mws_network_connectivity_config" "this" {
  count     = var.enable_serverless_connectivity ? 1 : 0
  provider  = databricks.mws
  name      = "${var.prefix}-ncc"
  region    = var.region
}

resource "databricks_account_network_policy" "this" {
  provider          = databricks.mws
  account_id        = var.databricks_account_id
  network_policy_id = "${var.prefix}-np" # Must not be more than 32 characters.

  egress = {
    network_access = {
      restriction_mode = "FULL_ACCESS"
      policy_enforcement = {
        enforcement_mode = "DRY_RUN"
      }
    }
  }
}

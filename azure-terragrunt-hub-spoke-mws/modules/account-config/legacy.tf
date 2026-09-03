# Account-level setting: disable legacy features for newly created workspaces
# (DBFS root/mounts, Hive Metastore provisioning, no-isolation clusters, DBR < 13.3 LTS).
# This is an account-scoped, global singleton — it can ONLY be used with the account
# provider (databricks.mws), which is why it lives here and not in workspace-config.
resource "databricks_disable_legacy_features_setting" "this" {
  count    = var.disable_legacy_features ? 1 : 0
  provider = databricks.mws
  disable_legacy_features {
    value = true
  }
}

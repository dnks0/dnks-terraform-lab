resource "databricks_disable_legacy_access_setting" "this" {
  provider = databricks.workspace
  count    = var.disable_legacy_access ? 1 : 0
  disable_legacy_access {
    value = true
  }
}

resource "databricks_disable_legacy_dbfs_setting" "this" {
  provider = databricks.workspace
  count    = var.disable_legacy_access ? 1 : 0
  disable_legacy_dbfs {
    value = true
  }
}

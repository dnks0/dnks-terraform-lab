resource "databricks_disable_legacy_access_setting" "this" {
  provider  = databricks.workspace
  disable_legacy_access {
    value = true
  }
}

resource "databricks_disable_legacy_dbfs_setting" "this" {
  provider  = databricks.workspace
  disable_legacy_dbfs {
    value = true
  }
}

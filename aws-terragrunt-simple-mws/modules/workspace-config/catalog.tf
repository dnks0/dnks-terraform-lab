resource "databricks_catalog" "this" {
  name      = replace(var.business_unit, "-", "_")
  provider  = databricks.workspace
}

resource "databricks_default_namespace_setting" "this" {
  provider  = databricks.workspace
  namespace {
    value = databricks_catalog.this.name
  }
}

resource "databricks_grant" "this" {
  catalog = databricks_catalog.this.name
  provider  = databricks.workspace
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

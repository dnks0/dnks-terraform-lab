resource "databricks_schema" "this" {
  provider     = databricks.workspace
  catalog_name = var.catalog
  name         = "sat"
  comment      = "schema for security-analysis-tool"
}

resource "databricks_grant" "schema" {
  schema   = databricks_schema.this.id
  provider  = databricks.workspace
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

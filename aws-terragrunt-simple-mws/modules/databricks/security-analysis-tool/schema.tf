resource "databricks_schema" "this" {
  provider      = databricks.workspace
  catalog_name  = var.catalog
  name          = "sat"
  comment       = "schema for security-analysis-tool"
  force_destroy = true
}

resource "databricks_grant" "schema" {
  provider   = databricks.workspace
  schema     = databricks_schema.this.id
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

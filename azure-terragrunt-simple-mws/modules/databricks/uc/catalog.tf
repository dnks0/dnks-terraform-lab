# Unity Catalog objects for the BU: storage credential -> external location -> catalog
# -> schema, plus grants and the workspace default namespace. The underlying Azure storage
# and access connector are owned by the `storage` unit and consumed via variables.

resource "databricks_storage_credential" "this" {
  provider = databricks.workspace
  name     = "${var.prefix}-storage-credential"
  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }
}

resource "databricks_external_location" "this" {
  provider        = databricks.workspace
  name            = "${var.prefix}-external-location"
  url             = "abfss://${var.storage_container_name}@${var.storage_account_dfs_host}/"
  credential_name = databricks_storage_credential.this.id
  comment         = "External location for workspace ${var.workspace_name}"
  force_destroy   = true
  depends_on = [
    databricks_storage_credential.this,
  ]
}

resource "databricks_catalog" "this" {
  name           = replace(var.business_unit, "-", "_")
  provider       = databricks.workspace
  comment        = "Default catalog of workspace ${var.workspace_name}"
  isolation_mode = "ISOLATED"
  storage_root   = databricks_external_location.this.url
  force_destroy  = true
  depends_on     = [databricks_storage_credential.this, databricks_external_location.this]
}

resource "databricks_schema" "this" {
  provider      = databricks.workspace
  catalog_name  = databricks_catalog.this.id
  name          = "default"
  comment       = "Default schema"
  force_destroy = true
}

resource "databricks_default_namespace_setting" "this" {
  provider = databricks.workspace
  namespace {
    value = databricks_catalog.this.name
  }
}

resource "databricks_grant" "storage-credential" {
  provider           = databricks.workspace
  storage_credential = databricks_storage_credential.this.id
  principal          = var.admin_group
  privileges         = ["ALL_PRIVILEGES", "MANAGE"]
}

resource "databricks_grant" "external-location" {
  provider          = databricks.workspace
  external_location = databricks_external_location.this.id
  principal         = var.admin_group
  privileges        = ["ALL_PRIVILEGES", "MANAGE"]
}

resource "databricks_grant" "catalog" {
  provider   = databricks.workspace
  catalog    = databricks_catalog.this.name
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

resource "databricks_grant" "schema" {
  provider   = databricks.workspace
  schema     = databricks_schema.this.id
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

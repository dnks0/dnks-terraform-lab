resource "databricks_storage_credential" "this" {
  provider  = databricks.workspace
  name      = "${var.prefix}-storage-credential"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.this.id
  }
}

resource "databricks_external_location" "this" {
  provider        = databricks.workspace
  name            = "${var.prefix}-external-location"
  url             = "abfss://${azurerm_storage_container.this.name}@${azurerm_storage_account.this.primary_dfs_host}/"
  credential_name = databricks_storage_credential.this.id
  comment         = "External location for workspace ${var.workspace_name}"
  force_destroy   = true
  depends_on      = [
    databricks_storage_credential.this,
    azurerm_storage_container.this,
    azurerm_storage_account.this,
  ]
}

resource "databricks_catalog" "this" {
  name            = replace(var.business_unit, "-", "_")
  provider        = databricks.workspace
  comment         = "Default catalog of workspace ${var.workspace_name}"
  isolation_mode  = "ISOLATED"
  storage_root    = databricks_external_location.this.url
  force_destroy   = true
  depends_on      = [databricks_storage_credential.this, databricks_external_location.this]
}

resource "databricks_schema" "this" {
  provider      = databricks.workspace
  catalog_name  = databricks_catalog.this.id
  name          = "default"
  comment       = "Default schema"
  force_destroy = true
}

resource "databricks_default_namespace_setting" "this" {
  provider  = databricks.workspace
  namespace {
    value = databricks_catalog.this.name
  }
}

resource "databricks_grant" "storage-credential" {
  storage_credential   = databricks_storage_credential.this.id
  provider  = databricks.workspace
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

resource "databricks_grant" "external-location" {
  external_location   = databricks_external_location.this.id
  provider  = databricks.workspace
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

resource "databricks_grant" "catalog" {
  catalog = databricks_catalog.this.name
  provider  = databricks.workspace
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

resource "databricks_grant" "schema" {
  schema   = databricks_schema.this.id
  provider  = databricks.workspace
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

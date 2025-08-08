resource "databricks_secret_scope" "this" {
  name          = var.secret_scope
  provider     = databricks.workspace
}

resource "databricks_secret" "user_email" {
  key          = "user-email-for-alerts"
  string_value = var.notification_email == "" ? data.databricks_current_user.me.user_name : var.notification_email
  scope        = databricks_secret_scope.this.id
  provider     = databricks.workspace
}

resource "databricks_secret" "account_console_id" {
  key          = "account-console-id"
  string_value = var.databricks_account_id
  scope        = databricks_secret_scope.this.id
  provider     = databricks.workspace
}

resource "databricks_secret" "sql_warehouse_id" {
  key          = "sql-warehouse-id"
  string_value = var.sql_warehouse_id
  scope        = databricks_secret_scope.this.id
  provider     = databricks.workspace
}

resource "databricks_secret" "analysis_schema_name" {
  key          = "analysis_schema_name"
  string_value = replace("${var.catalog}.${databricks_schema.this.name}", "-", "_")
  scope        = databricks_secret_scope.this.id
  provider     = databricks.workspace
}

resource "databricks_secret" "proxies" {
  key          = "proxies"
  string_value = jsonencode(var.proxies)
  scope        = databricks_secret_scope.this.id
  provider     = databricks.workspace
}

resource "databricks_secret" "use_sp_auth" {
  key          = "use-sp-auth"
  string_value = var.use_sp_auth
  scope        = databricks_secret_scope.this.id
  provider     = databricks.workspace
}

resource "databricks_secret" "client_id" {
  key          = "client-id"
  string_value = var.arm_client_id
  scope        = databricks_secret_scope.this.id
  provider     = databricks.workspace
}

resource "databricks_secret" "client_secret" {
  key          = "client-secret"
  string_value = var.arm_client_secret
  scope        = databricks_secret_scope.this.id
  provider     = databricks.workspace
}

resource "databricks_secret" "subscription_id" {
  key          = "subscription-id"
  string_value = var.arm_subscription_id
  scope        = databricks_secret_scope.this.id
  provider     = databricks.workspace
}

resource "databricks_secret" "tenant_id" {
  key          = "tenant-id"
  string_value = var.arm_tenant_id
  scope        = databricks_secret_scope.this.id
  provider     = databricks.workspace
}

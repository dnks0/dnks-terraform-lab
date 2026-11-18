resource "databricks_secret_scope" "this" {
  provider = databricks.workspace
  name     = var.secret_scope
}

resource "databricks_secret" "user_email" {
  provider     = databricks.workspace
  key          = "user-email-for-alerts"
  string_value = var.notification_email == "" ? data.databricks_current_user.me.user_name : var.notification_email
  scope        = databricks_secret_scope.this.id
}

resource "databricks_secret" "account_console_id" {
  provider     = databricks.workspace
  key          = "account-console-id"
  string_value = var.databricks_account_id
  scope        = databricks_secret_scope.this.id
}

resource "databricks_secret" "sql_warehouse_id" {
  provider     = databricks.workspace
  key          = "sql-warehouse-id"
  string_value = var.sql_warehouse_id
  scope        = databricks_secret_scope.this.id
}

resource "databricks_secret" "analysis_schema_name" {
  provider     = databricks.workspace
  key          = "analysis_schema_name"
  string_value = replace("${var.catalog}.${databricks_schema.this.name}", "-", "_")
  scope        = databricks_secret_scope.this.id
}

resource "databricks_secret" "proxies" {
  provider     = databricks.workspace
  key          = "proxies"
  string_value = jsonencode(var.proxies)
  scope        = databricks_secret_scope.this.id
}

resource "databricks_secret" "user" {
  provider     = databricks.workspace
  key          = "user"
  string_value = var.account_user
  scope        = databricks_secret_scope.this.id
}

resource "databricks_secret" "pass" {
  provider     = databricks.workspace
  key          = "pass"
  string_value = var.account_password
  scope        = databricks_secret_scope.this.id
}

resource "databricks_secret" "use_sp_auth" {
  provider     = databricks.workspace
  key          = "use-sp-auth"
  string_value = var.use_sp_auth
  scope        = databricks_secret_scope.this.id
}

resource "databricks_secret" "client_id" {
  provider     = databricks.workspace
  key          = "client-id"
  string_value = var.databricks_account_client_id
  scope        = databricks_secret_scope.this.id
}

resource "databricks_secret" "client_secret" {
  provider     = databricks.workspace
  key          = "client-secret"
  string_value = var.databricks_account_client_secret
  scope        = databricks_secret_scope.this.id
}

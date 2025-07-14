locals {
  databricks_account_admins = var.databricks_account_admins == [] ? [data.databricks_service_principal.this.id] : var.databricks_account_admins
}

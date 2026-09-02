locals {
  databricks_account_admins = length(var.databricks_account_admins) == 0 ? [data.databricks_service_principal.this.id] : var.databricks_account_admins
}

data "databricks_service_principal" "this" {
  provider       = databricks.mws
  application_id = var.arm_client_id
}

data "databricks_user" "account-admins" {
  provider = databricks.mws
  # Human admins only; the deploying SP is added separately (groups.tf). Empty => no lookup.
  for_each  = toset(var.databricks_account_admins)
  user_name = each.key
}

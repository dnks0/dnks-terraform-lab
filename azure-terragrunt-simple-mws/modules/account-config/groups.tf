resource "databricks_group" "admin_group" {
  provider      = databricks.mws
  display_name  = "${var.prefix}-admins"
}

resource "databricks_group_member" "service-principal-admin-member" {
  provider  = databricks.mws
  group_id  = databricks_group.admin_group.id
  member_id = data.databricks_service_principal.this.id
}

resource "databricks_group_member" "account-admin-members" {
  for_each  = toset(local.databricks_account_admins)
  provider  = databricks.mws
  group_id  = databricks_group.admin_group.id
  member_id = data.databricks_user.account-admins[each.value].id
}

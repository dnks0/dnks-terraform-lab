# Serverless / network-policy bindings to the workspace. Gated on the upstream IDs being
# non-empty (account-config emits "" when the corresponding feature flag is off), which keeps
# the count keyed off a plan-time-known value.
resource "databricks_mws_ncc_binding" "this" {
  count                          = var.ncc_id != "" ? 1 : 0
  provider                       = databricks.mws
  network_connectivity_config_id = var.ncc_id
  workspace_id                   = databricks_mws_workspaces.this.workspace_id
}

resource "databricks_workspace_network_option" "this" {
  count             = var.np_id != "" ? 1 : 0
  provider          = databricks.mws
  network_policy_id = var.np_id
  workspace_id      = databricks_mws_workspaces.this.workspace_id
}

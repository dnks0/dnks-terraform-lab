# databricks/uc — Unity Catalog governance for the BU: the UC IAM role + managed policy, the
# storage credential, external location, catalog, default schema and grants. Workspace-scoped
# (databricks.workspace). The UC IAM role lives here (not in the storage unit) because its trust
# policy is built from the storage credential's external_id, so role and credential must share a
# state (external_id cycle). Consumes the data bucket from the storage unit and the workspace host
# from the workspace unit.

provider "databricks" {
  alias = "workspace"
  host  = var.workspace_host
}

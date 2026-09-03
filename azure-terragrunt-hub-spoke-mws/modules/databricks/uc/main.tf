# The workspace-scoped databricks provider. Authentication configured via env.
provider "databricks" {
  alias = "workspace"
  host  = var.workspace_host
}

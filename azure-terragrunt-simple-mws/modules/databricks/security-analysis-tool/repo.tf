#Make sure Files in Repos option is enabled in Workspace Admin Console > Workspace Settings

resource "databricks_repo" "this" {
  url    = "https://github.com/databricks-industry-solutions/security-analysis-tool.git"
  branch = "main"
  path   = "/Applications/security-analysis-tool"
  provider  = databricks.workspace
}

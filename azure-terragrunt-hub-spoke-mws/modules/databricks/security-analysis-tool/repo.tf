#Make sure Files in Repos option is enabled in Workspace Admin Console > Workspace Settings

resource "databricks_repo" "this" {
  url      = "https://github.com/databricks-industry-solutions/security-analysis-tool.git"
  tag      = local.sat_release_tag
  path     = "/Applications/security-analysis-tool"
  provider = databricks.workspace
}

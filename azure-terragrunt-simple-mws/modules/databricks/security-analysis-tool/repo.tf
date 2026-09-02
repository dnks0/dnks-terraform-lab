#Make sure Files in Repos option is enabled in Workspace Admin Console > Workspace Settings

locals {
  # tag_name of the newest SAT release; handles the repo's inconsistent tagging (e.g. "0.9.0" vs "v0.8.0").
  sat_release_tag = jsondecode(data.http.sat_latest_release.response_body).tag_name
}

resource "databricks_repo" "this" {
  url      = "https://github.com/databricks-industry-solutions/security-analysis-tool.git"
  tag      = local.sat_release_tag
  path     = "/Applications/security-analysis-tool"
  provider = databricks.workspace
}

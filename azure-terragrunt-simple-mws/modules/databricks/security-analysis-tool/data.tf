data "databricks_current_user" "me" {
  provider = databricks.workspace
}

data "databricks_node_type" "smallest" {
  provider              = databricks.workspace
  local_disk            = true
  min_cores             = 4
  gb_per_core           = 8
  photon_worker_capable = true
  photon_driver_capable = true
}

data "databricks_spark_version" "latest-lts" {
  provider          = databricks.workspace
  long_term_support = true
}

# Newest published GitHub release of the SAT source repo, so the repo checkout tracks the
# latest release instead of the moving main branch. Re-read every plan, so a new SAT release
# is picked up on the next apply. Uses the unauthenticated GitHub API (60 requests/hour/IP).
data "http" "sat_latest_release" {
  url = "https://api.github.com/repos/databricks-industry-solutions/security-analysis-tool/releases/latest"
  request_headers = {
    Accept = "application/vnd.github+json"
  }
  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "GitHub releases API returned status ${self.status_code} when resolving the latest SAT release tag (rate limit or repo/API change?)."
    }
  }
}

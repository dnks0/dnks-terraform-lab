locals {
  # tag_name of the newest SAT release; handles the repo's inconsistent tagging (e.g. "0.9.0" vs "v0.8.0").
  sat_release_tag = jsondecode(data.http.sat_latest_release.response_body).tag_name
}

locals {
  # Use the explicit var.release_tag if set; otherwise the tag_name of the newest SAT release
  # (reading tag_name directly handles the repo's inconsistent tagging, e.g. "0.9.0" vs "v0.8.0").
  sat_release_tag = var.release_tag != "" ? var.release_tag : jsondecode(data.http.sat_latest_release[0].response_body).tag_name
}

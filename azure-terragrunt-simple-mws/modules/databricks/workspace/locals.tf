locals {
  workspace_root_storage_name = join("", ["dbxworkspaceroot", random_string.this.result])
}

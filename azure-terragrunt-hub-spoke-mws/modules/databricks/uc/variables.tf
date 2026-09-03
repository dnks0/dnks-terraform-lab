variable "prefix" {
  type        = string
  description = "Prefix to use for any resources"
}

variable "business_unit" {
  type        = string
  description = "Name of the BU (used as the catalog name)"
}

variable "admin_group" {
  type        = string
  description = "Name of the Databricks admin group to grant on the UC objects"
}

variable "workspace_host" {
  type        = string
  description = "Workspace host URL (for the workspace-scoped databricks provider)"
}

variable "workspace_name" {
  type        = string
  description = "Workspace name (used in comments)"
}

variable "access_connector_id" {
  type        = string
  description = "ID of the access connector (managed identity), supplied by the storage unit"
}

variable "storage_container_name" {
  type        = string
  description = "Name of the storage container, supplied by the storage unit"
}

variable "storage_account_dfs_host" {
  type        = string
  description = "Primary DFS host of the storage account, supplied by the storage unit"
}

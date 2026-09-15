variable "prefix" {
  type        = string
  description = "Prefix to use for any resources"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

variable "business_unit" {
  type        = string
  description = "Name of the BU (used as the catalog name, with '-' replaced by '_')"
}

variable "admin_group" {
  type        = string
  description = "Name of the Databricks admin group granted on the UC objects"
}

variable "workspace_host" {
  type        = string
  description = "Workspace host URL (for the workspace-scoped databricks provider)"
}

variable "workspace_name" {
  type        = string
  description = "Workspace name (used in UC object comments)"
}

variable "bucket_name" {
  type        = string
  description = "Name of the UC data bucket (from the storage unit)"
}

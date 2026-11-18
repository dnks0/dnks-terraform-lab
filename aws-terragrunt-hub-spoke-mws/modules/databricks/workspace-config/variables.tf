variable "business_unit" {
  type        = string
  description = "Name of the BU (used to name the sample cluster and warehouse)"
}

variable "workspace_host" {
  type        = string
  description = "Workspace host URL (for the workspace-scoped databricks provider)"
}

variable "enable_default_compute" {
  type        = bool
  description = "Create the sample single-node cluster + serverless warehouse and clean up the starter warehouse"
  default     = true
}

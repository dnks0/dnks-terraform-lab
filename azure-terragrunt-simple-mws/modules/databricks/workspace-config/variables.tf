variable "business_unit" {
  type        = string
  description = "Name of the BU"
}

variable "workspace_host" {
  type        = string
  description = "Workspace Host URL"
}

variable "enable_default_compute" {
  type        = bool
  description = "Create the sample single-node cluster and serverless SQL warehouse"
  default     = true
}

variable "disable_starter_warehouse" {
  type        = bool
  description = "Delete the auto-provisioned Starter Warehouse that Databricks creates for the workspace"
  default     = true
}

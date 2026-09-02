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
  description = "Create the sample single-node cluster and serverless SQL warehouse, and remove the auto-provisioned Starter Warehouse"
  default     = true
}

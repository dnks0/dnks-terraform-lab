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

variable "disable_legacy_access" {
  type        = bool
  description = "Apply the disable-legacy-access and disable-legacy-dbfs workspace settings"
  default     = true
}

variable "business_unit" {
  type        = string
  description = "Name of the BU"
}

variable "admin_group" {
  type        = string
  description = "Name of the Databricks admin group"
}

variable "workspace_host" {
  type        = string
  description = "Workspace Host URL"
}

variable "system_schemas" {
  type        = list(string)
  description = "List of system schemas to enable"
  default  = ["access", "billing", "compute", "lakeflow", "marketplace", "storage", "query", "serving"]
}

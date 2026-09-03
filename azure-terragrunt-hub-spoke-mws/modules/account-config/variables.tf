variable "prefix" {
  type        = string
  description = "Prefix to use for any resources"
}

variable "region" {
  type        = string
  description = "The Azure region to deploy to"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "arm_client_id" {
  type        = string
  description = "Service Principal Client-ID"
}

variable "databricks_account_admins" {
  type        = list(string)
  description = <<EOT
  List of Admins to be added at account-level for Unity Catalog.
  Enter with square brackets and double quotes
  e.g ["first.admin@domain.com", "second.admin@domain.com"]
  EOT
}

variable "enable_serverless_connectivity" {
  type        = bool
  description = "Provision the serverless network connectivity config (NCC)"
  default     = false
}

variable "enable_network_policy" {
  type        = bool
  description = "Provision the account network policy (egress + ingress in DRY_RUN / observe-only mode)"
  default     = false
}

variable "disable_legacy_features" {
  type        = bool
  description = "Disable legacy features (DBFS root/mounts, Hive Metastore, no-isolation clusters, DBR < 13.3 LTS) for newly created workspaces — account-global setting"
  default     = true
}

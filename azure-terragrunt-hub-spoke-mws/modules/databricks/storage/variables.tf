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
  default     = {}
}

variable "resource_group_name" {
  type        = string
  description = "Name of the (BU-owned) resource group, supplied by the network unit"
}

variable "privatelink_subnet_id" {
  type        = string
  description = "ID of the privatelink subnet, supplied by the network unit"
}

variable "dns_zone_ids" {
  type = object({
    dfs  = string
    blob = string
  })
  description = "Private DNS zone IDs (dfs, blob) supplied by the network unit"
}

variable "account_replication_type" {
  type        = string
  description = "Replication type for the storage account"
  default     = "GRS"
}

variable "enable_storage_privatelink" {
  type        = bool
  description = "Create dfs/blob private endpoints for the external-location storage account"
  default     = true
}

variable "enable_serverless_connectivity" {
  type        = bool
  description = "Associate the storage account with the Databricks NSP (transition mode) so serverless compute can reach it. The perimeter itself is created in the databricks/network unit. Same flag as the account-level NCC."
  default     = false
}

variable "nsp_profile_id" {
  type        = string
  description = "NSP profile ID (from the databricks/network unit) to associate this storage account with"
  default     = ""
}

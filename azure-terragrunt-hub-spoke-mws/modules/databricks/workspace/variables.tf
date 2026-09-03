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

variable "databricks_metastore_ids" {
  type        = list(string)
  description = "Databricks Metastore IDs"
}

variable "databricks_account_admin_group_id" {
  type        = string
  description = "Databricks Account Admin group ID"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the (BU-owned) resource group to deploy the workspace into"
}

variable "network_configuration" {
  type = object({
    virtual_network_id                  = string
    host_subnet_name                    = string
    container_subnet_name               = string
    privatelink_subnet_id               = string
    host_subnet_nsg_association_id      = string
    container_subnet_nsg_association_id = string
  })
  description = "Network wiring supplied by the network unit"
}

variable "dns_zone_ids" {
  type = object({
    classic = string
    dfs     = string
    blob    = string
  })
  description = "Private DNS zone IDs supplied by the network unit"
}

variable "enable_classic_privatelink" {
  type        = bool
  description = "Create classic Private Link endpoints (ui/api + dfs + blob)"
  default     = true
}

variable "ncc_id" {
  description = "ID of the network-connectivity-configuration for this workspace"
  type        = string
  default     = ""
}

variable "np_id" {
  description = "ID of the network policy for this workspace"
  type        = string
  default     = ""
}

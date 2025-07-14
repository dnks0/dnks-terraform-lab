variable "prefix" {
  type        = string
  description = "Prefix to use for any resources"
}

variable "region" {
  type        = string
  description = "The AWS region to deploy to"
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

variable "vnet_cidrs" {
  type        = list(string)
  description = "(Required) The CIDR blocks for the Virtual Network"

  # Add validation for the CIDR block
  validation {
    condition     = length([
      for cidr in var.vnet_cidrs : true
      if tonumber(split("/", cidr)[1]) > 15 && tonumber(split("/", cidr)[1]) < 25
    ]) == length(var.vnet_cidrs)

    error_message = "CIDR blocks must be betweem /16 and /24, inclusive"
  }
}

variable "container_subnet_cidrs" {
  type        = list(string)
  description = "(Required) The CIDR blocks for the container subnet"
}

variable "host_subnet_cidrs" {
  type        = list(string)
  description = "(Required) The CIDR blocks for the host subnet"
}

variable "privatelink_subnet_cidrs" {
  type        = list(string)
  description = "(Required) The CIDR blocks for the privatelink subnet"
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

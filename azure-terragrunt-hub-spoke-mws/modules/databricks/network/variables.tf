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

# --- supplied by the generic network unit ---
variable "resource_group_name" {
  type        = string
  description = "Name of the BU resource group"
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the BU virtual network"
}

variable "virtual_network_id" {
  type        = string
  description = "ID of the BU virtual network (for DNS zone links)"
}

# --- subnet CIDRs ---
variable "container_subnet_cidrs" {
  type        = list(string)
  description = "(Required) CIDR blocks for the container (private) subnet"
}

variable "host_subnet_cidrs" {
  type        = list(string)
  description = "(Required) CIDR blocks for the host (public) subnet"
}

variable "privatelink_subnet_cidrs" {
  type        = list(string)
  description = "(Required) CIDR blocks for the privatelink subnet"
}

# --- feature flags controlling which private DNS zones are created ---
variable "enable_classic_privatelink" {
  type        = bool
  description = "Whether classic Private Link is used (creates classic + dfs + blob DNS zones)"
  default     = true
}

variable "enable_storage_privatelink" {
  type        = bool
  description = "Whether external-location Private Link is used (creates dfs + blob DNS zones)"
  default     = true
}

variable "enable_serverless_connectivity" {
  type        = bool
  description = "Create the Azure Network Security Perimeter (+ profile + Databricks serverless inbound rule) that the storage account associates with, so serverless compute can reach storage. Same flag as the account-level NCC."
  default     = false
}

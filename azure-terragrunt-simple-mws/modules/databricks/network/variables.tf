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

variable "enable_outbound_nat" {
  type        = bool
  description = "Whether a NAT gateway exists (in the network unit) to associate Databricks subnets with. Must match the network unit's flag; known at plan time."
  default     = true
}

variable "nat_gateway_id" {
  type        = string
  description = "NAT gateway ID to associate Databricks subnets with; empty string when disabled"
  default     = ""
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
  description = "Whether backend Private Link is used (creates backend + dfs + blob DNS zones)"
  default     = true
}

variable "enable_storage_privatelink" {
  type        = bool
  description = "Whether external-location Private Link is used (creates dfs + blob DNS zones)"
  default     = true
}

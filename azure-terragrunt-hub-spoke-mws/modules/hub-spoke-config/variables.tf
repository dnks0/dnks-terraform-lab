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

# --- hub side (supplied by the hub unit) ---
variable "hub_resource_group_name" {
  type        = string
  description = "(Required) The name of the hub Resource Group to peer"
}

variable "hub_vnet_id" {
  type        = string
  description = "(Required) The id of the hub VNet to peer"
}

variable "hub_vnet_name" {
  type        = string
  description = "(Required) The name of the hub VNet to peer"
}

variable "hub_route_table_id" {
  type        = string
  description = "(Required) The ID of the route table to associate with the Databricks spoke subnets"
}

variable "hub_ipgroup_id" {
  type        = string
  description = "(Required) The ID of the IP Group used for firewall egress rules"
}

# --- spoke side (supplied by the network + databricks/network units) ---
variable "spoke_resource_group_name" {
  type        = string
  description = "(Required) The name of the spoke Resource Group to peer"
}

variable "spoke_vnet_id" {
  type        = string
  description = "(Required) The id of the spoke VNet to peer"
}

variable "spoke_vnet_name" {
  type        = string
  description = "(Required) The name of the spoke VNet to peer"
}

variable "spoke_subnet_ids" {
  type = object({
    host      = string
    container = string
  })
  description = "(Required) The delegated Databricks subnet IDs to route through the firewall"
}

variable "spoke_subnet_cidrs" {
  type = object({
    host      = list(string)
    container = list(string)
  })
  description = "(Required) The delegated Databricks subnet CIDRs to add to the firewall IP group"
}

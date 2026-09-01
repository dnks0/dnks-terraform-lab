variable "zone_name" {
  type        = string
  description = "(Required) Private DNS zone name (e.g. privatelink.dfs.core.windows.net)"
}

variable "link_name" {
  type        = string
  description = "(Required) Name of the virtual network link"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Resource group to create the zone in"
}

variable "virtual_network_id" {
  type        = string
  description = "(Required) ID of the virtual network to link the zone to"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to attach"
  default     = {}
}

variable "name" {
  type        = string
  description = "(Required) Name of the subnet"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Resource group of the parent VNet"
}

variable "virtual_network_name" {
  type        = string
  description = "(Required) Name of the parent virtual network"
}

variable "address_prefixes" {
  type        = list(string)
  description = "(Required) CIDR blocks for the subnet"
}

variable "delegation" {
  type = object({
    name         = string
    service_name = string
    actions      = list(string)
  })
  description = "(Optional) Subnet delegation. Null for no delegation."
  default     = null
}

variable "network_security_group_id" {
  type        = string
  description = "(Optional) NSG to associate with this subnet. Null for no association."
  default     = null
}

variable "nat_gateway_id" {
  type        = string
  description = "(Optional) NAT gateway to associate with this subnet. Null for no association."
  default     = null
}

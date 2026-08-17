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

variable "associate_network_security_group" {
  type        = bool
  description = "(Optional) Whether to associate an NSG with this subnet. Gated separately from the ID because the ID may be unknown at plan time."
  default     = false
}

variable "network_security_group_id" {
  type        = string
  description = "(Optional) NSG to associate with this subnet. Used only when associate_network_security_group is true."
  default     = null
}

variable "associate_nat_gateway" {
  type        = bool
  description = "(Optional) Whether to associate a NAT gateway with this subnet. Gated separately from the ID because the ID may be unknown at plan time."
  default     = false
}

variable "nat_gateway_id" {
  type        = string
  description = "(Optional) NAT gateway to associate with this subnet. Used only when associate_nat_gateway is true."
  default     = null
}

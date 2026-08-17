variable "name" {
  type        = string
  description = "(Required) Name of the network security group"
}

variable "location" {
  type        = string
  description = "(Required) Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Resource group to create the NSG in"
}

variable "security_rules" {
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = optional(string, "*")
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  description = "(Optional) Map of security rules keyed by rule name"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to attach"
  default     = {}
}

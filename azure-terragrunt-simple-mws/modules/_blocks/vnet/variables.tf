variable "name" {
  type        = string
  description = "(Required) Name of the virtual network"
}

variable "location" {
  type        = string
  description = "(Required) Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Resource group to create the VNet in"
}

variable "address_space" {
  type        = list(string)
  description = "(Required) CIDR blocks for the virtual network"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to attach"
  default     = {}
}

variable "name" {
  type        = string
  description = "Name of the IP group"
}

variable "location" {
  type        = string
  description = "The Azure region to deploy to"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into"
}

variable "cidrs" {
  type        = list(string)
  description = "CIDRs to seed the IP group with (may be empty and populated via azurerm_ip_group_cidr)"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

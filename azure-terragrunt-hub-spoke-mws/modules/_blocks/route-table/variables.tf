variable "name" {
  type        = string
  description = "Name of the route table"
}

variable "location" {
  type        = string
  description = "The Azure region to deploy to"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into"
}

variable "routes" {
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  description = "Routes to create in the route table"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

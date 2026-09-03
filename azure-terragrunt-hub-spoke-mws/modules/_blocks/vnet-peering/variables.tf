variable "left_vnet_name" {
  type        = string
  description = "Name of the left VNet (spoke)"
}

variable "left_vnet_id" {
  type        = string
  description = "ID of the left VNet (spoke)"
}

variable "left_resource_group_name" {
  type        = string
  description = "Resource group of the left VNet (spoke)"
}

variable "right_vnet_name" {
  type        = string
  description = "Name of the right VNet (hub)"
}

variable "right_vnet_id" {
  type        = string
  description = "ID of the right VNet (hub)"
}

variable "right_resource_group_name" {
  type        = string
  description = "Resource group of the right VNet (hub)"
}

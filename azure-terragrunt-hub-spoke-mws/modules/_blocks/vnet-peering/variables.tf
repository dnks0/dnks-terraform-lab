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

# Peering resource names. Default to from-<left>-to-<right>-peering / the reverse, but that
# concatenates both full VNet names and can exceed Azure's 80-char peering-name limit for long
# VNet names — so callers with long names should pass shorter explicit names.
variable "left_to_right_name" {
  type        = string
  description = "Name of the left->right peering (default: from-<left>-to-<right>-peering)"
  default     = ""
}

variable "right_to_left_name" {
  type        = string
  description = "Name of the right->left peering (default: from-<right>-to-<left>-peering)"
  default     = ""
}

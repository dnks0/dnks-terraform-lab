variable "name" {
  type        = string
  description = "(Required) Name of the NAT gateway"
}

variable "public_ip_name" {
  type        = string
  description = "(Required) Name of the NAT public IP"
}

variable "location" {
  type        = string
  description = "(Required) Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Resource group to create the NAT resources in"
}

variable "sku_name" {
  type        = string
  description = "(Optional) SKU for the NAT gateway and public IP"
  default     = "StandardV2"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to attach"
  default     = {}
}

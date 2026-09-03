variable "name" {
  type        = string
  description = "Name of the firewall (used as the base for its public IP and policy names)"
}

variable "location" {
  type        = string
  description = "The Azure region to deploy to"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into"
}

variable "firewall_subnet_id" {
  type        = string
  description = "ID of the AzureFirewallSubnet the firewall attaches to"
}

variable "sku_tier" {
  type        = string
  description = "Firewall SKU tier"
  default     = "Standard"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

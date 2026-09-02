variable "prefix" {
  type        = string
  description = "Prefix to use for any resources"
}

variable "region" {
  type        = string
  description = "The Azure region to deploy to"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the BU resource group (owned by the resource-group unit)"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

variable "vnet_cidrs" {
  type        = list(string)
  description = "(Required) The CIDR blocks for the Virtual Network"

  validation {
    condition = length([
      for cidr in var.vnet_cidrs : true
      if tonumber(split("/", cidr)[1]) > 15 && tonumber(split("/", cidr)[1]) < 25
    ]) == length(var.vnet_cidrs)
    error_message = "CIDR blocks must be between /16 and /24, inclusive"
  }
}

variable "extra_subnets" {
  type = map(object({
    address_prefixes = list(string)
  }))
  description = <<EOT
  (Optional) Generic subnets to create in the VNet for non-Databricks workloads.
  Keyed by a short name; the subnet is named "$${prefix}-$${key}-snt". No delegation,
  NSG or NAT association is applied — wire those from the consuming workload.
  EOT
  default     = {}
}

variable "enable_outbound_nat" {
  type        = bool
  description = "(Optional) Create a NAT gateway for the VNet (associated to Databricks subnets by databricks/network)"
  default     = true
}

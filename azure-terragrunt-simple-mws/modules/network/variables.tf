variable "prefix" {
  type        = string
  description = "Prefix to use for any resources"
}

variable "region" {
  type        = string
  description = "The Azure region to deploy to"
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

variable "container_subnet_cidrs" {
  type        = list(string)
  description = "(Required) The CIDR blocks for the container (private) subnet"
}

variable "host_subnet_cidrs" {
  type        = list(string)
  description = "(Required) The CIDR blocks for the host (public) subnet"
}

variable "privatelink_subnet_cidrs" {
  type        = list(string)
  description = "(Required) The CIDR blocks for the privatelink subnet"
}

variable "extra_subnets" {
  type = map(object({
    address_prefixes = list(string)
  }))
  description = <<EOT
  (Optional) Additional subnets to create in the VNet for non-Databricks workloads.
  Keyed by a short name; the subnet is named "$${prefix}-$${key}-snt". No delegation,
  NSG or NAT association is applied — wire those from the consuming workload.
  EOT
  default     = {}
}

variable "enable_nat_gateway" {
  type        = bool
  description = "(Optional) Create a NAT gateway and associate the Databricks subnets with it"
  default     = true
}

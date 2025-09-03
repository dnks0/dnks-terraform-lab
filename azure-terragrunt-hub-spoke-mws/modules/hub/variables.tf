variable "prefix" {
  type        = string
  description = "Prefix to use for any resources"
}

variable "region" {
  type        = string
  description = "The AWS region to deploy to"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
}

variable "vnet_cidrs" {
  type        = list(string)
  description = "(Required) The CIDR blocks for the hub Virtual Network"

  # Add validation for the CIDR block
  validation {
    condition     = length([
      for cidr in var.vnet_cidrs : true
      if tonumber(split("/", cidr)[1]) > 15 && tonumber(split("/", cidr)[1]) < 25
    ]) == length(var.vnet_cidrs)

    error_message = "CIDR blocks must be betweem /16 and /24, inclusive"
  }
}

variable "firewall_subnets_cidr" {
  type        = list(string)
  description = "(Required) The CIDR block for the firewall subnet"
}

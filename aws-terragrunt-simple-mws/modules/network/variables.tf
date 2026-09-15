variable "prefix" {
  type        = string
  description = "Prefix to use for any resources"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

variable "vpc_cidr" {
  type        = string
  description = "(Required) The CIDR block for the VPC"

  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) < 24
    error_message = "CIDR block must be at least as large as /23"
  }
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "(Required) The CIDR blocks for the public subnets (one per AZ; also drives how many AZs are used)"
}

variable "enable_outbound_nat" {
  type        = bool
  description = "(Optional) Create per-AZ NAT gateways for outbound egress (routed to by databricks/network's private subnets)"
  default     = true
}

variable "extra_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = <<EOT
  (Optional) Generic subnets to create in the VPC for non-Databricks workloads.
  Keyed by a short name; the subnet is named "$${prefix}-$${key}-snt". No routing is applied —
  wire route-table associations from the consuming workload.
  EOT
  default     = {}
}

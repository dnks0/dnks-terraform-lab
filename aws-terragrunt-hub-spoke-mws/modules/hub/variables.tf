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
  description = "(Required) The CIDR block for the hub VPC"

  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) < 24
    error_message = "CIDR block must be at least as large as /23"
  }
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "(Required) CIDR blocks for the public (NAT) subnets, one per AZ; also drives how many AZs are used"
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "(Required) CIDR blocks for the private (Transit Gateway attachment) subnets, one per AZ. Must not be longer than public_subnets_cidr: entry i routes through the NAT gateway in AZ i"
}

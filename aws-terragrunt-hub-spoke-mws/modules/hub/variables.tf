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

variable "vpc_cidr" {
  type        = string
  description = "(Required) The CIDR block for the Virtual Network"

  # Add validation for the CIDR block
  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) < 24
    error_message = "CIDR block must be at least as large as /23"
  }
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "(Required) The CIDR block for private subnet"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "(Required) The CIDR block for public subnets"
}

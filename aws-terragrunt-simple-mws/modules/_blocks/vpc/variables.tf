variable "name" {
  type        = string
  description = "Name of the VPC (also used as the Name tag and the IGW name prefix)"
}

variable "cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in the VPC"
  default     = true
}

variable "create_igw" {
  type        = bool
  description = "Create an internet gateway attached to the VPC"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

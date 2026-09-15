variable "name" {
  type        = string
  description = "Name of the subnet (Name tag)"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to create the subnet in"
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the subnet"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the subnet"
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Auto-assign public IPs to instances launched in this subnet"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

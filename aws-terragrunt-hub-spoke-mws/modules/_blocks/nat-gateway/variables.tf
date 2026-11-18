variable "name" {
  type        = string
  description = "Name of the NAT gateway (Name tag)"
}

variable "eip_name" {
  type        = string
  description = "Name of the Elastic IP (Name tag)"
}

variable "subnet_id" {
  type        = string
  description = "ID of the public subnet to place the NAT gateway in"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

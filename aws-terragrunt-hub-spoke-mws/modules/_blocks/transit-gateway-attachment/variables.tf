variable "name" {
  type        = string
  description = "Name of the attachment (Name tag)"
}

variable "purpose" {
  type        = string
  description = "Purpose tag, e.g. \"Transit Gateway Attachment - Hub VPC\""
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to attach"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets (one per AZ) the attachment places its network interfaces in"
}

variable "transit_gateway_id" {
  type        = string
  description = "ID of the Transit Gateway to attach to"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

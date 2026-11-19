variable "prefix" {
  type        = string
  description = "Prefix to use for any resources"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

variable "hub_transit_gateway_id" {
  type        = string
  description = "(Required) ID of the hub Transit Gateway"
}

variable "hub_private_route_table_ids" {
  type        = list(string)
  description = "(Required) Hub private (TGW attachment) route table IDs that need the spoke return route"
}

variable "hub_public_route_table_ids" {
  type        = list(string)
  description = "(Required) Hub public (NAT) route table IDs that need the spoke return route"
}

variable "spoke_vpc_id" {
  type        = string
  description = "(Required) ID of the spoke VPC"
}

variable "spoke_vpc_cidr" {
  type        = string
  description = "(Required) CIDR block of the spoke VPC"
}

variable "spoke_tgw_subnet_ids" {
  type        = list(string)
  description = "(Required) Spoke subnets for the Transit Gateway attachment, one per AZ"
}

variable "spoke_private_route_table_ids" {
  type        = list(string)
  description = "(Required) Spoke private route table IDs that get the 0.0.0.0/0 → TGW egress route"
}

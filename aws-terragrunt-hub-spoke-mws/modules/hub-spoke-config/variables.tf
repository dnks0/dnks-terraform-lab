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

variable "hub_transit_gateway_id" {
  type        = string
  description = "(Required) ID of the transit-gateway in the Hub"
}

variable "hub_private_route_table_ids" {
  type        = list(string)
  description = "(Required) ID of the transit-gateway private subnet route table in the Hub"
}

variable "hub_public_route_table_ids" {
  type        = list(string)
  description = "(Required) The IDs for nat-gateway public subnet route tables in the Hub"
}

variable "spoke_vpc_id" {
  type        = string
  description = "(Required) The ID the spoke Virtual Network"
}

variable "spoke_vpc_cidr" {
  type        = string
  description = "(Required) The CIDR block the spoke Virtual Network"
}

variable "spoke_tgw_subnet_ids" {
  type        = list(string)
  description = "(Required) The IDs for transit-gateway subnets in the spoke Virtual Network"
}

variable "spoke_private_route_table_ids" {
  type        = list(string)
  description = "(Required) The IDs for transit-gateway private subnet route tables"
}

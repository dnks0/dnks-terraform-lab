variable "name" {
  type        = string
  description = "(Required) Name of the private endpoint"
}

variable "location" {
  type        = string
  description = "(Required) Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Resource group to create the endpoint in"
}

variable "subnet_id" {
  type        = string
  description = "(Required) Subnet to place the private endpoint in"
}

variable "connection_name" {
  type        = string
  description = "(Required) Name of the private service connection"
}

variable "private_connection_resource_id" {
  type        = string
  description = "(Required) Target resource ID the endpoint connects to"
}

variable "subresource_names" {
  type        = list(string)
  description = "(Required) Subresource names (e.g. [\"dfs\"], [\"databricks_ui_api\"])"
}

variable "dns_zone_group_name" {
  type        = string
  description = "(Required) Name of the private DNS zone group"
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "(Required) Private DNS zone IDs to register the endpoint in"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to attach"
  default     = {}
}

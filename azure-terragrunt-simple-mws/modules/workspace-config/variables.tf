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

variable "business_unit" {
  type        = string
  description = "Name of the BU"
}

variable "admin_group" {
  type        = string
  description = "Name of the Databricks admin group"
}

variable "workspace_host" {
  type        = string
  description = "Workspace Host URL"
}

variable "workspace_name" {
  type        = string
  description = "Workspace Name"
}

variable "azure_resource_group_name" {
  type        = string
  description = "Name of the Azure resource group"
}

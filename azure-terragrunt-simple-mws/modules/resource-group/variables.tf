variable "prefix" {
  type        = string
  description = "Prefix to use for the resource group name"
}

variable "region" {
  type        = string
  description = "The Azure region to deploy to"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to the resource group"
  default     = {}
}

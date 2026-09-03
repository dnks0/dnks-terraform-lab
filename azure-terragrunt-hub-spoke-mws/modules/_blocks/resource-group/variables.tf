variable "name" {
  type        = string
  description = "(Required) Name of the resource group"
}

variable "location" {
  type        = string
  description = "(Required) Azure region"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to attach"
  default     = {}
}

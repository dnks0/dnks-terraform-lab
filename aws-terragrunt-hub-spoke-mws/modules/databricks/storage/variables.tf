variable "prefix" {
  type        = string
  description = "Prefix to use for any resources (the bucket is named \"$${prefix}-bucket\")"
}

variable "force_destroy" {
  type        = bool
  description = "Allow deleting the data bucket even when it contains objects"
  default     = true
}

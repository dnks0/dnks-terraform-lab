variable "name" {
  type        = string
  description = "Name of the Transit Gateway (Name tag)"
}

variable "description" {
  type        = string
  description = "Description of the Transit Gateway"
  default     = "Transit Gateway for Hub/Spoke"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

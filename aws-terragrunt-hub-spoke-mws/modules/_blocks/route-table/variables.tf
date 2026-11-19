variable "name" {
  type        = string
  description = "Name of the route table (Name tag)"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to create the route table in"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs to associate with this route table"
  default     = []
}

variable "routes" {
  type = list(object({
    cidr_block     = string
    gateway_id     = optional(string)
    nat_gateway_id = optional(string)
  }))
  description = "Routes to add. Each entry sets exactly one target (gateway_id or nat_gateway_id)."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

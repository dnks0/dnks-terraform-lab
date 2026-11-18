variable "name" {
  type        = string
  description = "Name of the security group"
}

variable "description" {
  type        = string
  description = "Description of the security group"
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to create the security group in"
}

variable "ingress_rules" {
  type = map(object({
    description     = optional(string, "")
    from_port       = number
    to_port         = number
    protocol        = optional(string, "tcp")
    self            = optional(bool, false)
    security_groups = optional(list(string), [])
    cidr_blocks     = optional(list(string), [])
  }))
  description = "Ingress rules, keyed by a stable name. Each rule sets its source via self / security_groups / cidr_blocks."
  default     = {}
}

variable "egress_rules" {
  type = map(object({
    description     = optional(string, "")
    from_port       = number
    to_port         = number
    protocol        = optional(string, "tcp")
    self            = optional(bool, false)
    security_groups = optional(list(string), [])
    cidr_blocks     = optional(list(string), [])
  }))
  description = "Egress rules, keyed by a stable name. Omitting all egress rules leaves the group with no egress."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

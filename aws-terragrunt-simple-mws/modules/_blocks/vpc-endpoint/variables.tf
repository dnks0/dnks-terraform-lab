variable "name" {
  type        = string
  description = "Name of the VPC endpoint (Name tag)"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to create the endpoint in"
}

variable "service_name" {
  type        = string
  description = "Service name for the endpoint (e.g. com.amazonaws.<region>.s3 or a PrivateLink service name)"
}

variable "endpoint_type" {
  type        = string
  description = "Endpoint type: Gateway or Interface"

  validation {
    condition     = contains(["Gateway", "Interface"], var.endpoint_type)
    error_message = "endpoint_type must be Gateway or Interface"
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for an Interface endpoint"
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs for an Interface endpoint"
  default     = []
}

variable "private_dns_enabled" {
  type        = bool
  description = "Enable private DNS for an Interface endpoint"
  default     = false
}

variable "route_table_ids" {
  type        = list(string)
  description = "Route table IDs for a Gateway endpoint"
  default     = []
}

variable "policy" {
  type        = string
  description = "Endpoint policy JSON; null for the default full-access policy"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

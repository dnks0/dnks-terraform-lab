variable "name" {
  type        = string
  description = "Name of the IAM role"
}

variable "assume_role_policy" {
  type        = string
  description = "Trust policy (assume-role policy) JSON for the role"
}

variable "inline_policy" {
  type        = string
  description = "Optional inline policy JSON attached to the role (aws_iam_role_policy); null to skip"
  default     = null
}

variable "inline_policy_name" {
  type        = string
  description = "Name for the inline policy (required when inline_policy is set)"
  default     = null
}

variable "managed_policy" {
  type        = string
  description = "Optional customer managed policy JSON, created and attached to the role; null to skip"
  default     = null
}

variable "managed_policy_name" {
  type        = string
  description = "Name for the managed policy (required when managed_policy is set)"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
  default     = {}
}

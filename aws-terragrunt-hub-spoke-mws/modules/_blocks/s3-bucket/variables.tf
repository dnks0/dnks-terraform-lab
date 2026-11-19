variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "force_destroy" {
  type        = bool
  description = "Allow deleting the bucket even when it contains objects"
  default     = false
}

variable "versioning_status" {
  type        = string
  description = "Versioning status: Enabled, Suspended or Disabled"
  default     = "Disabled"
}

variable "sse_algorithm" {
  type        = string
  description = "Default server-side encryption algorithm"
  default     = "AES256"
}

variable "policy" {
  type        = string
  description = "Optional bucket policy JSON; null to skip (policy changes are ignored once set)"
  default     = null
}

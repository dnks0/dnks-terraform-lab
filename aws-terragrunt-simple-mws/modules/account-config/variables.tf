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

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "databricks_account_client_id" {
  type        = string
  description = "Service Principal Client-ID"
}

variable "databricks_account_admins" {
  type        = list(string)
  description = <<EOT
  List of Admins to be added at account-level for Unity Catalog.
  Enter with square brackets and double quotes
  e.g ["first.admin@domain.com", "second.admin@domain.com"]
  EOT
}

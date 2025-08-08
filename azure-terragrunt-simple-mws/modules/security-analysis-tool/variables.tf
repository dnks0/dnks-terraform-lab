variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "arm_client_id" {
  type        = string
  description = "Service Principal Client-ID"
}

variable "arm_client_secret" {
  type        = string
  description = "Service Principal Client-Secret"
}

variable "workspace_host" {
  type        = string
  description = "Workspace Host URL"
}

variable "sql_warehouse_id" {
  type        = string
  description = "ID of the sql warehouse to use"
}

variable "catalog" {
  type        = string
  description = "Name of the catalog to use"
}

variable "admin_group" {
  type        = string
  description = "Name of the Databricks admin group"
}

variable "serverless" {
  description = "Flag to run SAT initializer/Driver on Serverless"
  type        = bool
}

variable "use_sp_auth" {
  description = "Authenticate with Service Principal OAuth tokens instead of user and password"
  type        = bool
  default     = true
}

variable "proxies" {
  description = "Proxies to be used for Databricks API calls"
  type        = map(any)
}

variable "arm_subscription_id" {
  description = "Azure subscriptionId"
  type        = string
}

variable "arm_tenant_id" {
  description = "The Directory (tenant) ID for the application registered in Azure AD"
  type        = string
}

variable "secret_scope" {
  description = "Name of secret scope for security-analysis-tool secrets"
  type        = string
  default     = "sat_scope"
}

variable "notification_email" {
  type        = string
  description = "Optional user email for notifications. If not specified, current user's email will be used"
  default     = ""
}

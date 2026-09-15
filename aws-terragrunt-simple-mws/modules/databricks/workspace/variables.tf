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
  default     = {}
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "databricks_metastore_ids" {
  type        = list(string)
  description = "Databricks Metastore IDs to assign to the workspace"
}

variable "databricks_account_admin_group_id" {
  type        = string
  description = "Databricks account admin group ID to grant workspace ADMIN"
}

# --- Consumed from databricks/network ---
variable "network_configuration" {
  type = object({
    vpc_id                  = string
    private_subnet_ids      = list(string)
    intra_subnet_ids        = list(string)
    private_route_table_ids = list(string)
  })
  description = "Network wiring from databricks/network (databricks_mws_networks consumes vpc_id + private_subnet_ids)"
}

variable "workspace_security_group_id" {
  type        = string
  description = "Databricks workspace security group ID (from databricks/network)"
}

variable "backend_rest_endpoint_id" {
  type        = string
  description = "AWS VPC endpoint ID for the backend REST endpoint (from databricks/network); \"\" when PrivateLink disabled"
  default     = ""
}

variable "backend_relay_endpoint_id" {
  type        = string
  description = "AWS VPC endpoint ID for the backend relay endpoint (from databricks/network); \"\" when PrivateLink disabled"
  default     = ""
}

# --- Consumed from account-config ---
variable "ncc_id" {
  type        = string
  description = "Network connectivity config ID to bind to the workspace; \"\" to skip"
  default     = ""
}

variable "np_id" {
  type        = string
  description = "Account network policy ID to apply to the workspace; \"\" to skip"
  default     = ""
}

# --- Feature flags ---
variable "enable_classic_privatelink" {
  type        = bool
  description = "Register the backend PrivateLink endpoints (mws_vpc_endpoint) and wire them into mws_networks"
  default     = true
}

# --- Reserved extension points (not built yet) ---
variable "enable_inbound_privatelink" {
  type        = bool
  description = "Reserved: require front-end PrivateLink (flips PAS public_access_enabled/level)"
  default     = false
}

variable "enable_cmk" {
  type        = bool
  description = "Reserved: customer-managed keys for managed services + workspace storage"
  default     = false
}

variable "enable_security_compliance_addon" {
  type        = bool
  description = "Reserved: enable the compliance security profile add-on"
  default     = false
}

# MWS bootstrap chain: credentials + storage config + network registration + private access
# settings + the workspace itself + metastore/permission assignments. The AWS-native network
# resources (VPC endpoints, SGs, subnets) are owned by databricks/network and consumed here via
# var.network_configuration / var.workspace_security_group_id / var.backend_*_endpoint_id.

# Wait on credential due to race condition:
# https://kb.databricks.com/en_US/terraform/failed-credential-validation-checks-error-with-terraform
resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on      = [null_resource.previous]
  create_duration = "30s"
}

resource "databricks_mws_credentials" "this" {
  provider         = databricks.mws
  role_arn         = module.crossaccount_role.arn
  credentials_name = "${var.prefix}-credentials"
  depends_on       = [time_sleep.wait_30_seconds]
}

resource "databricks_mws_storage_configurations" "this" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = module.root_bucket.bucket
  storage_configuration_name = "${var.prefix}-storage"
}

# Backend PrivateLink endpoint registrations (gated on classic PrivateLink). The underlying
# aws_vpc_endpoints live in databricks/network; their IDs arrive via var.backend_*_endpoint_id.
resource "databricks_mws_vpc_endpoint" "backend_rest" {
  provider            = databricks.mws
  count               = var.enable_classic_privatelink ? 1 : 0
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = var.backend_rest_endpoint_id
  vpc_endpoint_name   = "${var.prefix}-vpce-backend"
  region              = var.region
}

resource "databricks_mws_vpc_endpoint" "backend_relay" {
  provider            = databricks.mws
  count               = var.enable_classic_privatelink ? 1 : 0
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = var.backend_relay_endpoint_id
  vpc_endpoint_name   = "${var.prefix}-vpce-relay"
  region              = var.region
}

resource "databricks_mws_networks" "this" {
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "${var.prefix}-network"
  security_group_ids = [var.workspace_security_group_id]
  subnet_ids         = var.network_configuration.private_subnet_ids
  vpc_id             = var.network_configuration.vpc_id

  dynamic "vpc_endpoints" {
    for_each = var.enable_classic_privatelink ? [1] : []
    content {
      dataplane_relay = [databricks_mws_vpc_endpoint.backend_relay[0].vpc_endpoint_id]
      rest_api        = [databricks_mws_vpc_endpoint.backend_rest[0].vpc_endpoint_id]
    }
  }
}

resource "databricks_mws_private_access_settings" "this" {
  provider                     = databricks.mws
  private_access_settings_name = "${var.prefix}-pas"
  region                       = var.region
  # Extension point (var.enable_inbound_privatelink): flip public_access_enabled to false and set
  # private_access_level = "ENDPOINT" to require front-end PrivateLink and disable public access.
  public_access_enabled = !var.enable_inbound_privatelink
  private_access_level  = "ACCOUNT"
}

resource "databricks_mws_workspaces" "this" {
  provider       = databricks.mws
  account_id     = var.databricks_account_id
  aws_region     = var.region
  workspace_name = "${var.prefix}-workspace"
  pricing_tier   = "ENTERPRISE"

  # Extension point (var.enable_cmk): managed_services_customer_managed_key_id +
  # storage_customer_managed_key_id (with aws_kms_key + databricks_mws_customer_managed_keys).
  # Extension point (var.enable_security_compliance_addon): compliance_security_profile via
  # databricks workspace settings.

  credentials_id             = databricks_mws_credentials.this.credentials_id
  storage_configuration_id   = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id                 = databricks_mws_networks.this.network_id
  private_access_settings_id = databricks_mws_private_access_settings.this.private_access_settings_id

  depends_on = [
    databricks_mws_networks.this,
    databricks_mws_credentials.this,
    databricks_mws_storage_configurations.this,
    databricks_mws_private_access_settings.this
  ]
}

resource "databricks_metastore_assignment" "this" {
  provider     = databricks.mws
  for_each     = toset(var.databricks_metastore_ids)
  workspace_id = databricks_mws_workspaces.this.workspace_id
  metastore_id = each.value
}

# Sleeping to wait for the workspace to enable identity federation.
resource "time_sleep" "wait_for_permission_apis" {
  depends_on      = [databricks_metastore_assignment.this]
  create_duration = "20s"
}

resource "databricks_mws_permission_assignment" "account-admins" {
  provider     = databricks.mws
  workspace_id = databricks_mws_workspaces.this.workspace_id
  principal_id = var.databricks_account_admin_group_id
  permissions  = ["ADMIN"]
  depends_on   = [time_sleep.wait_for_permission_apis]
}

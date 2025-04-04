# Wait on Credential Due to Race Condition
# https://kb.databricks.com/en_US/terraform/failed-credential-validation-checks-error-with-terraform
resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]
  create_duration = "30s"
}

# Credential Configuration
resource "databricks_mws_credentials" "this" {
  provider          = databricks.mws
  role_arn          = aws_iam_role.this.arn
  credentials_name  = "${var.prefix}-credentials"
  depends_on        = [time_sleep.wait_30_seconds]
}

# Storage Configuration
resource "databricks_mws_storage_configurations" "this" {
  provider                    = databricks.mws
  account_id                  = var.databricks_account_id
  bucket_name                 = aws_s3_bucket.this.id
  storage_configuration_name  = "${var.prefix}-storage"
}

# Backend REST VPC Endpoint Configuration
resource "databricks_mws_vpc_endpoint" "backend_rest" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.backend_rest.id
  vpc_endpoint_name   = "${var.prefix}-vpce-backend"
  region              = var.region
}

# Backend Rest VPC Endpoint Configuration
resource "databricks_mws_vpc_endpoint" "backend_relay" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.backend_relay.id
  vpc_endpoint_name   = "${var.prefix}-vpce-relay"
  region              = var.region
}

# Network Configuration
resource "databricks_mws_networks" "this" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  network_name        = "${var.prefix}-network"
  security_group_ids  = [for sg in aws_security_group.this : sg.id]
  subnet_ids          = module.vpc[0].private_subnets
  vpc_id              = module.vpc[0].vpc_id
  vpc_endpoints {
    dataplane_relay  = [databricks_mws_vpc_endpoint.backend_relay.vpc_endpoint_id]
    rest_api         = [databricks_mws_vpc_endpoint.backend_rest.vpc_endpoint_id]
  }
}

// Private Access Setting Configuration
resource "databricks_mws_private_access_settings" "this" {
  provider                      = databricks.mws
  private_access_settings_name  = "${var.prefix}-pas"
  region                        = var.region
  public_access_enabled         = true
  private_access_level          = "ACCOUNT"
}

resource "databricks_mws_workspaces" "this" {
  provider                    = databricks.mws
  account_id                  = var.databricks_account_id
  aws_region                  = var.region
  workspace_name              = "${var.prefix}-workspace"
  pricing_tier                = "ENTERPRISE"

  credentials_id              = databricks_mws_credentials.this.credentials_id
  storage_configuration_id    = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id                  = databricks_mws_networks.this.network_id
  private_access_settings_id  = databricks_mws_private_access_settings.this.private_access_settings_id

  depends_on = [
    databricks_mws_networks.this,
    databricks_mws_credentials.this,
    databricks_mws_storage_configurations.this,
    databricks_mws_private_access_settings.this
  ]
}

resource "databricks_metastore_assignment" "this" {
  provider              = databricks.mws
  for_each              = toset(var.databricks_metastore_ids)
  workspace_id          = databricks_mws_workspaces.this.workspace_id
  metastore_id          = each.value
}

# sleeping for 20s to wait for the workspace to enable identity federation
resource "time_sleep" "wait_for_permission_apis" {
  depends_on = [
    databricks_metastore_assignment.this
  ]
  create_duration = "20s"
}

resource "databricks_mws_permission_assignment" "account-admins" {
  provider      = databricks.mws
  workspace_id  = databricks_mws_workspaces.this.workspace_id
  principal_id  = var.databricks_account_admin_group_id
  permissions  = ["ADMIN"]
  depends_on = [
    time_sleep.wait_for_permission_apis,
  ]
}

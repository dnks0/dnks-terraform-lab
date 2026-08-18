# Define an Azure Databricks workspace resource.
# Networking (vnet/subnets/nsg/nat/dns) is owned by the `network` unit and supplied via
# var.network_configuration; the resource group is likewise owned upstream.
resource "azurerm_databricks_workspace" "this" {
  name                        = "${var.prefix}-workspace"
  resource_group_name         = var.resource_group_name
  managed_resource_group_name = "${var.prefix}-managed-rg"
  location                    = var.region
  sku                         = "premium"

  # Extension point (var.enable_frontend_privatelink): flip to false and add a frontend
  # (browser_authentication) private endpoint to disable public network access.
  public_network_access_enabled         = true
  network_security_group_rules_required = "NoAzureDatabricksRules"

  # Extension point (var.cmk_enabled): managed_disk_cmk_key_vault_key_id,
  # managed_services_cmk_key_vault_key_id, customer_managed_key_enabled,
  # infrastructure_encryption_enabled.
  #
  # Extension point (var.enable_compliance_profile): enhanced_security_compliance { ... }
  # (compliance_security_profile_enabled, enhanced_security_monitoring_enabled,
  # automatic_cluster_update_enabled).

  custom_parameters {
    storage_account_name                                 = local.workspace_root_storage_name
    no_public_ip                                         = true
    virtual_network_id                                   = var.network_configuration.virtual_network_id
    public_subnet_name                                   = var.network_configuration.host_subnet_name
    private_subnet_name                                  = var.network_configuration.container_subnet_name
    public_subnet_network_security_group_association_id  = var.network_configuration.host_subnet_nsg_association_id
    private_subnet_network_security_group_association_id = var.network_configuration.container_subnet_nsg_association_id
  }

  tags = var.tags
}

resource "databricks_metastore_assignment" "this" {
  provider     = databricks.mws
  for_each     = toset(var.databricks_metastore_ids)
  workspace_id = azurerm_databricks_workspace.this.workspace_id
  metastore_id = each.value
}

# sleeping for 20s to wait for the workspace to enable identity federation
resource "time_sleep" "wait_for_permission_apis" {
  depends_on = [
    databricks_metastore_assignment.this
  ]
  create_duration = "20s"
}

resource "databricks_mws_permission_assignment" "account-admins" {
  provider     = databricks.mws
  workspace_id = azurerm_databricks_workspace.this.workspace_id
  principal_id = var.databricks_account_admin_group_id
  permissions  = ["ADMIN"]
  depends_on = [
    time_sleep.wait_for_permission_apis,
  ]
}

# Define an Azure Databricks workspace resource
resource "azurerm_databricks_workspace" "this" {
  name                        = "${var.prefix}-workspace"
  resource_group_name         = azurerm_resource_group.this.name
  managed_resource_group_name = "${var.prefix}-managed-rg"
  location                    = var.region
  sku                         = "premium"

  public_network_access_enabled         = true
  network_security_group_rules_required = "NoAzureDatabricksRules"

  custom_parameters {
    storage_account_name                                 = local.workspace_root_storage_name
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.this.id
    public_subnet_name                                   = azurerm_subnet.host.name
    private_subnet_name                                  = azurerm_subnet.container.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.host.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.container.id
  }

  tags = var.tags
}

resource "databricks_metastore_assignment" "this" {
  provider              = databricks.mws
  for_each              = toset(var.databricks_metastore_ids)
  workspace_id          = azurerm_databricks_workspace.this.workspace_id
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
  workspace_id  = azurerm_databricks_workspace.this.workspace_id
  principal_id  = var.databricks_account_admin_group_id
  permissions  = ["ADMIN"]
  depends_on = [
    time_sleep.wait_for_permission_apis,
  ]
}

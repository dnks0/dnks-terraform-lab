resource "azurerm_databricks_access_connector" "this" {
  name                = "${var.prefix}-dbx-mi"
  resource_group_name = var.azure_resource_group_name
  location            = var.region
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

resource "azurerm_storage_account" "this" {
  name                            = replace(var.prefix, "-", "")
  resource_group_name             = var.azure_resource_group_name
  location                        = var.region
  tags                            = var.tags
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  is_hns_enabled                  = true
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass         = ["None"]
    private_link_access {
      endpoint_resource_id = azurerm_databricks_access_connector.this.id
    }
    ip_rules = [
      local.ifconfig_co_json.ip
    ]
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_container" "this" {
  name                    = "${var.prefix}-cnt"
  storage_account_id      = azurerm_storage_account.this.id
  container_access_type   = "private"
  depends_on = [
    azurerm_role_assignment.blob_data_contrib,
    azurerm_role_assignment.event_contrib,
    azurerm_role_assignment.queue_contrib
  ]
}

# Define an Azure role assignment resource
resource "azurerm_role_assignment" "blob_data_contrib" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "queue_contrib" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_databricks_access_connector.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "event_contrib" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "EventGrid EventSubscription Contributor"
  principal_id         = azurerm_databricks_access_connector.this.identity[0].principal_id
}

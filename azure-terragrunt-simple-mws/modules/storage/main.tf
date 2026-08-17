# storage — Unity Catalog external-location storage for the BU.
# Azure storage account + access connector (managed identity) + role assignments, plus
# optional dfs/blob private endpoints. Data lives here and outlives any single workspace,
# hence its own state. The UC objects (credential/external-location/catalog) live in the
# `uc` unit and consume this module's outputs.

data "http" "deployer_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  deployer_ip = jsondecode(data.http.deployer_ip.response_body).ip
}

resource "azurerm_databricks_access_connector" "this" {
  name                = "${var.prefix}-dbx-mi"
  resource_group_name = var.resource_group_name
  location            = var.region
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

resource "azurerm_storage_account" "this" {
  name                            = replace(var.prefix, "-", "")
  resource_group_name             = var.resource_group_name
  location                        = var.region
  tags                            = var.tags
  account_tier                    = "Standard"
  account_replication_type        = var.account_replication_type
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
      local.deployer_ip
    ]
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_container" "this" {
  name                  = "${var.prefix}-cnt"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
  depends_on = [
    azurerm_role_assignment.blob_data_contrib,
    azurerm_role_assignment.event_contrib,
    azurerm_role_assignment.queue_contrib
  ]
}

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

module "dfs_private_endpoint" {
  source                         = "../_blocks/private_endpoint"
  count                          = var.enable_external_location_privatelink ? 1 : 0
  name                           = "${var.prefix}-extlctn-dfs-pep"
  location                       = var.region
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.privatelink_subnet_id
  connection_name                = "pl-${var.prefix}-extlctn-dfs"
  private_connection_resource_id = azurerm_storage_account.this.id
  subresource_names              = ["dfs"]
  dns_zone_group_name            = "private-dns-zone-dbx-extlctn-dfs"
  private_dns_zone_ids           = [var.dns_zone_ids.dfs]
  tags                           = var.tags
}

module "blob_private_endpoint" {
  source                         = "../_blocks/private_endpoint"
  count                          = var.enable_external_location_privatelink ? 1 : 0
  name                           = "${var.prefix}-extlctn-blob-pep"
  location                       = var.region
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.privatelink_subnet_id
  connection_name                = "pl-${var.prefix}-extlctn-blob"
  private_connection_resource_id = azurerm_storage_account.this.id
  subresource_names              = ["blob"]
  dns_zone_group_name            = "private-dns-zone-dbx-extlctn-blob"
  private_dns_zone_ids           = [var.dns_zone_ids.blob]
  tags                           = var.tags
}

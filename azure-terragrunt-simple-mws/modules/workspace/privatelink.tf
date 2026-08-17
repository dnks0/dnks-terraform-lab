# Backend Private Link private endpoints for the workspace (ui/api) and its managed root
# storage (dfs + blob). The private DNS zones and subnet are owned by the `network` unit
# and consumed here via var.dns_zone_ids / var.network_configuration.
#
# Gated by var.enable_backend_privatelink (default true). The DNS zones themselves always
# exist upstream, so disabling this only removes the endpoints.

resource "azurerm_private_endpoint" "backend" {
  count               = var.enable_backend_privatelink ? 1 : 0
  name                = "${var.prefix}-backend-pep"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.network_configuration.privatelink_subnet_id

  private_service_connection {
    name                           = "pl-${var.prefix}-backend"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dbx-backend"
    private_dns_zone_ids = [var.dns_zone_ids.backend]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "dfs" {
  count               = var.enable_backend_privatelink ? 1 : 0
  name                = "${var.prefix}-dfs-pep"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.network_configuration.privatelink_subnet_id

  private_service_connection {
    name                           = "pl-${var.prefix}-dfs"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/", local.workspace_root_storage_name])
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dbx-dfs"
    private_dns_zone_ids = [var.dns_zone_ids.dfs]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "blob" {
  count               = var.enable_backend_privatelink ? 1 : 0
  name                = "${var.prefix}-blob-pep"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.network_configuration.privatelink_subnet_id

  private_service_connection {
    name                           = "pl-${var.prefix}-dbx-blob"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/", local.workspace_root_storage_name])
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dbx-blob"
    private_dns_zone_ids = [var.dns_zone_ids.blob]
  }

  tags = var.tags
}

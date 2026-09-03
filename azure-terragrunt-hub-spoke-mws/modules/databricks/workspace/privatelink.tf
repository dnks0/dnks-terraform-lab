# Classic Private Link private endpoints for the workspace (ui/api) and its managed root
# storage (dfs + blob), composed from the shared _blocks/private-endpoint module. The private
# DNS zones and subnet are owned by the databricks/network unit and consumed here via
# var.dns_zone_ids / var.network_configuration.
#
# Gated by var.enable_classic_privatelink (default true). The DNS zones are gated on the same
# flag upstream, so whenever these endpoints exist their zones exist too.
module "classic_private_endpoint" {
  source                         = "../../_blocks/private-endpoint"
  count                          = var.enable_classic_privatelink ? 1 : 0
  name                           = "${var.prefix}-classic-pep"
  location                       = var.region
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.network_configuration.privatelink_subnet_id
  connection_name                = "pl-${var.prefix}-classic"
  private_connection_resource_id = azurerm_databricks_workspace.this.id
  subresource_names              = ["databricks_ui_api"]
  dns_zone_group_name            = "private-dns-zone-dbx-classic"
  private_dns_zone_ids           = [var.dns_zone_ids.classic]
  tags                           = var.tags
}

module "dfs_private_endpoint" {
  source                         = "../../_blocks/private-endpoint"
  count                          = var.enable_classic_privatelink ? 1 : 0
  name                           = "${var.prefix}-dfs-pep"
  location                       = var.region
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.network_configuration.privatelink_subnet_id
  connection_name                = "pl-${var.prefix}-dfs"
  private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/", local.workspace_root_storage_name])
  subresource_names              = ["dfs"]
  dns_zone_group_name            = "private-dns-zone-dbx-dfs"
  private_dns_zone_ids           = [var.dns_zone_ids.dfs]
  tags                           = var.tags
}

module "blob_private_endpoint" {
  source                         = "../../_blocks/private-endpoint"
  count                          = var.enable_classic_privatelink ? 1 : 0
  name                           = "${var.prefix}-blob-pep"
  location                       = var.region
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.network_configuration.privatelink_subnet_id
  connection_name                = "pl-${var.prefix}-dbx-blob"
  private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/", local.workspace_root_storage_name])
  subresource_names              = ["blob"]
  dns_zone_group_name            = "private-dns-zone-dbx-blob"
  private_dns_zone_ids           = [var.dns_zone_ids.blob]
  tags                           = var.tags
}

resource "azurerm_private_endpoint" "dfs" {
  name                = "${var.prefix}-extlctn-dfs-pep"
  location            = var.region
  resource_group_name = var.azure_resource_group_name
  subnet_id           = data.azurerm_subnet.privatelink.id

  # Define the private service connection for the dfs resource
  private_service_connection {
    name                           = "pl-${var.prefix}-extlctn-dfs"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  # Associate the private DNS zone with the private endpoint
  private_dns_zone_group {
    name                 = "private-dns-zone-dbx-extlctn-dfs"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.dfs.id]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "blob" {
  name                = "${var.prefix}-extlctn-blob-pep"
  location            = var.region
  resource_group_name = var.azure_resource_group_name
  subnet_id           = data.azurerm_subnet.privatelink.id

  # Define the private service connection for the blob resource
  private_service_connection {
    name                           = "pl-${var.prefix}-extlctn-blob"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  # Associate the private DNS zone with the private endpoint
  private_dns_zone_group {
    name                 = "private-dns-zone-dbx-extlctn-blob"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.blob.id]
  }

  tags = var.tags
}

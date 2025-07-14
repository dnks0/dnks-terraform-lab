# Define a private DNS zone resource for the backend
resource "azurerm_private_dns_zone" "backend" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.this.name

  tags = var.tags
}

# Define a virtual network link for the private DNS zone and the backend virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "backend" {
  name                  = "${var.prefix}-backend-vnl"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.backend.name
  virtual_network_id    = azurerm_virtual_network.this.id

  tags = var.tags
}

# Define a private endpoint resource for the backend
resource "azurerm_private_endpoint" "backend" {
  name                = "${var.prefix}-backend-pep"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.privatelink.id

  # Configure the private service connection
  private_service_connection {
    name                           = "pl-${var.prefix}-backend"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  # Configure the private DNS zone group
  private_dns_zone_group {
    name                 = "private-dns-zone-dbx-backend"
    private_dns_zone_ids = [azurerm_private_dns_zone.backend.id]
  }

  tags = var.tags
}

# Define a private DNS zone resource for storage: dfs
resource "azurerm_private_dns_zone" "dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
  tags = var.tags
  depends_on = [azurerm_databricks_workspace.this]
}

# Define a virtual network link for the private DNS zone and the backend virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "dfs" {
  name                  = "${var.prefix}-dbx-dfs-vnl"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dfs.name
  virtual_network_id    = azurerm_virtual_network.this.id

  tags = var.tags
}

resource "azurerm_private_endpoint" "dfs" {
  name                = "${var.prefix}-dfs-pep"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.privatelink.id

  # Define the private service connection for the dfs resource
  private_service_connection {
    name                           = "pl-${var.prefix}-dfs"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/", local.workspace_root_storage_name])
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  # Associate the private DNS zone with the private endpoint
  private_dns_zone_group {
    name                 = "private-dns-zone-dbx-dfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dfs.id]
  }

  tags = var.tags
}

# Define a private DNS zone resource for storage: blob
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
  tags = var.tags
  depends_on = [azurerm_databricks_workspace.this]
}

# Define a virtual network link for the private DNS zone and the backend virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "${var.prefix}-dbx-blob-vnl"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.this.id

  tags = var.tags
}

resource "azurerm_private_endpoint" "blob" {
  name                = "${var.prefix}-blob-pep"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.privatelink.id

  # Define the private service connection for the dfs resource
  private_service_connection {
    name                           = "pl-${var.prefix}-dbx-blob"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/", local.workspace_root_storage_name])
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  # Associate the private DNS zone with the private endpoint
  private_dns_zone_group {
    name                 = "private-dns-zone-dbx-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }

  tags = var.tags
}

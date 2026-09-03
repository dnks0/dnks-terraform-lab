resource "azurerm_network_security_perimeter_association" "this" {
  count                                 = var.enable_serverless_connectivity ? 1 : 0
  name                                  = "${var.prefix}-nsp-storage"
  network_security_perimeter_profile_id = var.nsp_profile_id
  resource_id                           = azurerm_storage_account.this.id
  access_mode                           = "Learning"
}

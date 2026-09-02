# Azure Network Security Perimeter for Databricks serverless -> storage access.
# The perimeter, profile and inbound service-tag rule are network-layer constructs, so they
# live here; the storage account's association to this perimeter is created in the storage
# unit (which owns the storage account). Gated by enable_serverless_connectivity — the same
# flag as the account-level NCC.
resource "azurerm_network_security_perimeter" "this" {
  count               = var.enable_serverless_connectivity ? 1 : 0
  name                = "${var.prefix}-nsp"
  resource_group_name = var.resource_group_name
  location            = var.region
  tags                = var.tags
}

resource "azurerm_network_security_perimeter_profile" "this" {
  count                         = var.enable_serverless_connectivity ? 1 : 0
  name                          = "${var.prefix}-nsp-profile"
  network_security_perimeter_id = azurerm_network_security_perimeter.this[0].id
}

# Allow the Databricks serverless regional service tag inbound to the perimeter.
resource "azurerm_network_security_perimeter_access_rule" "serverless" {
  count                                 = var.enable_serverless_connectivity ? 1 : 0
  name                                  = "allow-databricks-serverless"
  network_security_perimeter_profile_id = azurerm_network_security_perimeter_profile.this[0].id
  direction                             = "Inbound"
  service_tags                          = ["AzureDatabricksServerless.${var.region}"]
}

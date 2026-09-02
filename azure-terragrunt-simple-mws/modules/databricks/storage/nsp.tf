# Serverless -> storage access via an Azure Network Security Perimeter (NSP).
# Wraps the external-location storage account in an NSP and allows the Databricks serverless
# service tag inbound, so serverless compute can reach the storage. Gated by
# enable_serverless_connectivity (the same flag as the account-level NCC).
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

# Associate the storage account in transition mode. access_mode "Learning" is the provider's
# enum value for what Azure now calls "Transition" (the API kept the old name). Per Databricks
# guidance NSP must stay in transition, never Enforced: it evaluates NSP rules first and falls
# back to the storage firewall if none match, so it never blocks Databricks connectivity.
# (The storage account must also stay on "Enabled from selected networks", not "Secured by
# Perimeter", or serverless external-location access fails.)
resource "azurerm_network_security_perimeter_association" "storage" {
  count                                 = var.enable_serverless_connectivity ? 1 : 0
  name                                  = "${var.prefix}-nsp-storage"
  network_security_perimeter_profile_id = azurerm_network_security_perimeter_profile.this[0].id
  resource_id                           = azurerm_storage_account.this.id
  access_mode                           = "Learning"
}

# Allow the Databricks serverless regional service tag inbound to the perimeter.
resource "azurerm_network_security_perimeter_access_rule" "serverless" {
  count                                 = var.enable_serverless_connectivity ? 1 : 0
  name                                  = "allow-databricks-serverless"
  network_security_perimeter_profile_id = azurerm_network_security_perimeter_profile.this[0].id
  direction                             = "Inbound"
  service_tags                          = ["AzureDatabricksServerless.${var.region}"]
}

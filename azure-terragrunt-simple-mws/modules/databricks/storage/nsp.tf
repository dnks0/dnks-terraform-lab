# Serverless -> storage access via an Azure Network Security Perimeter (NSP).
#
# Wraps the external-location storage account in an NSP and allows inbound access from the
# AzureDatabricksServerless.<region> service tag, so Databricks serverless compute can reach
# the storage. Part of serverless connectivity — gated by enable_serverless_connectivity
# (same flag as the account-level NCC).
#
# access_mode is "Learning" — the azurerm provider's enum value for what Azure now calls
# "Transition mode" (the API value stayed "Learning" after the portal rename). Per Databricks
# guidance NSP must stay in transition mode, NOT Enforced: transition evaluates NSP rules
# first and falls back to the storage firewall rules if none match, so it never blocks
# Databricks connectivity. (The storage account also stays on "Enabled from selected
# networks", never "Secured by Perimeter", as the docs require.)
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

resource "azurerm_network_security_perimeter_association" "storage" {
  count                                 = var.enable_serverless_connectivity ? 1 : 0
  name                                  = "${var.prefix}-nsp-storage"
  network_security_perimeter_profile_id = azurerm_network_security_perimeter_profile.this[0].id
  resource_id                           = azurerm_storage_account.this.id
  access_mode                           = "Learning"
}

# Allow Databricks serverless compute (regional service tag) inbound to the perimeter.
resource "azurerm_network_security_perimeter_access_rule" "serverless" {
  count                                 = var.enable_serverless_connectivity ? 1 : 0
  name                                  = "allow-databricks-serverless"
  network_security_perimeter_profile_id = azurerm_network_security_perimeter_profile.this[0].id
  direction                             = "Inbound"
  service_tags                          = ["AzureDatabricksServerless.${var.region}"]
}

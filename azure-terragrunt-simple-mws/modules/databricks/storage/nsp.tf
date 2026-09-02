# Serverless -> storage access via an Azure Network Security Perimeter (NSP).
#
# Wraps the external-location storage account in an NSP and allows inbound access from the
# AzureDatabricksServerless.<region> service tag, so Databricks serverless compute can reach
# the storage. Part of serverless connectivity — gated by enable_serverless_connectivity
# (same flag as the account-level NCC).
#
# access_mode is Learning (not Enforced): per Databricks guidance NSP must run in
# Learning/transition mode with Databricks — it observes and logs but does not block, so it
# never breaks Databricks connectivity to the storage.
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

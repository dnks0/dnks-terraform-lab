# Associate the external-location storage account with the Databricks Network Security
# Perimeter. The perimeter, profile and serverless inbound rule are owned by the
# databricks/network unit; this unit only joins its own storage account to that profile.
#
# access_mode "Learning" is the provider's enum value for what Azure now calls "Transition"
# (the API kept the old name). Per Databricks guidance NSP must stay in transition, never
# Enforced: it evaluates NSP rules first and falls back to the storage firewall if none
# match, so it never blocks Databricks connectivity. (The storage account must also stay on
# "Enabled from selected networks", not "Secured by Perimeter", or serverless access fails.)
#
# Gated by enable_serverless_connectivity — the same flag that creates the perimeter upstream.
resource "azurerm_network_security_perimeter_association" "storage" {
  count                                 = var.enable_serverless_connectivity ? 1 : 0
  name                                  = "${var.prefix}-nsp-storage"
  network_security_perimeter_profile_id = var.nsp_profile_id
  resource_id                           = azurerm_storage_account.this.id
  access_mode                           = "Learning"
}

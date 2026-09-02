# Network connectivity config (NCC) for serverless — gated on its own flag.
resource "databricks_mws_network_connectivity_config" "this" {
  count    = var.enable_serverless_connectivity ? 1 : 0
  provider = databricks.mws
  name     = "${var.prefix}-ncc"
  region   = var.region
}

# Account network policy — a separate concern from the NCC, gated on its own flag.
# Egress and ingress are both configured permissively in DRY_RUN mode: policies are
# evaluated and violations logged, but nothing is blocked (a safe, observe-only baseline).
resource "databricks_account_network_policy" "this" {
  count             = var.enable_network_policy ? 1 : 0
  provider          = databricks.mws
  account_id        = var.databricks_account_id
  network_policy_id = "${var.prefix}-np" # Must not be more than 32 characters.

  egress = {
    network_access = {
      restriction_mode = "FULL_ACCESS"
      policy_enforcement = {
        enforcement_mode = "DRY_RUN"
      }
    }
  }

  # ingress_dry_run is the ingress equivalent of egress DRY_RUN: the ingress policy is
  # evaluated and logged but never blocks requests.
  ingress_dry_run = {
    public_access = {
      restriction_mode = "FULL_ACCESS"
    }
  }
}

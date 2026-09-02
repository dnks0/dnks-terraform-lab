# Network connectivity config (NCC) for serverless — gated on its own flag.
resource "databricks_mws_network_connectivity_config" "this" {
  count    = var.enable_serverless_connectivity ? 1 : 0
  provider = databricks.mws
  name     = "${var.prefix}-ncc"
  region   = var.region
}

# Account network policy — a separate concern from the NCC, gated on its own flag.
# Permissive "allow everything" baseline: egress is FULL_ACCESS (in DRY_RUN, observe-only)
# and ingress is an enforced FULL_ACCESS across all three ingress paths. All three ingress
# sub-modes are set explicitly to their most-permissive value so enforcement never blocks
# anything (important because this stack uses Private Link for workspace connectivity).
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

  ingress = {
    public_access = {
      restriction_mode = "FULL_ACCESS"
    }
    private_access = {
      restriction_mode = "ALLOW_ALL_REGISTERED_ENDPOINTS"
    }
    cross_workspace_access = {
      restriction_mode = "FULL_ACCESS"
    }
  }
}

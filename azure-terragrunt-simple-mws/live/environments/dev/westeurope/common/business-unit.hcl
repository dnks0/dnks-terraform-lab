locals {
  name = "common"

  # Optional per-business-unit feature-flag overrides for the shared "common" scope
  # (e.g. account-config). Merged over the environment/region levels; empty = inherit.
  #   features = {
  #     enable_network_policy = true
  #   }
  features = {}
}

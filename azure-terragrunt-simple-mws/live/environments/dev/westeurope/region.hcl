locals {
  name = "westeurope"

  # Optional per-region feature-flag overrides. Merged over the environment level and under
  # the business-unit/leaf levels; empty = inherit. Example — enable serverless connectivity
  # for everything in this region:
  #   features = {
  #     enable_serverless_connectivity = true
  #   }
  features = {}
}

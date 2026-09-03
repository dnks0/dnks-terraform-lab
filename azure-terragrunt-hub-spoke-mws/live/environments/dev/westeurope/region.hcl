locals {
  name = "westeurope"

  # Optional per-region feature-flag overrides. Merged over the environment level and under
  # the business-unit/leaf levels; empty = inherit. Example — disable classic Private Link
  # for everything in this region:
  #   features = {
  #     enable_classic_privatelink = false
  #   }
  features = {}
}

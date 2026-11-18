locals {
  name = "common"

  # Optional feature-flag overrides for account/common-scope units. Merged over the
  # environment/region levels; empty = inherit. See root.hcl.
  features = {}
}

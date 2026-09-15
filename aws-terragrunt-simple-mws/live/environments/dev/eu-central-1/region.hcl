locals {
  name = "eu-central-1"

  # Optional per-region feature-flag overrides. Merged over the environment level (and can
  # still be overridden per business-unit / leaf); empty = inherit. See root.hcl.
  features = {}
}

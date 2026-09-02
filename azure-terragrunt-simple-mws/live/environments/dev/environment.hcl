locals {
  name = "dev"

  # Optional per-environment feature-flag overrides. Merged over root.hcl's feature_baseline
  # (env → region → business-unit → leaf, most-specific wins); empty = inherit the baseline.
  # Example — turn on the compliance add-on for the whole dev environment:
  #   features = {
  #     enable_security_compliance_addon = true
  #   }
  features = {}
}

locals {
  name = "bu-1"

  # Optional per-business-unit feature-flag overrides. Merged over the environment/region
  # levels (and can still be overridden per leaf unit); empty = inherit. Example — this BU
  # turns off classic PrivateLink:
  #   features = {
  #     enable_classic_privatelink = false
  #   }
  features = {}
}

locals {
  name = "bu-1"

  # Optional per-business-unit feature-flag overrides. Merged over the environment/region
  # levels (and can still be overridden per leaf unit); empty = inherit. Example — this BU
  # opts out of the NAT gateway:
  #   features = {
  #     enable_outbound_nat = false
  #   }
  features = {}
}

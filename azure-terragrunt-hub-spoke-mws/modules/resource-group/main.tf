# resource-group — the BU-owned resource group, as its own unit/state.
# Owning the RG separately means it has an independent lifecycle: the network,
# storage and Databricks units deploy INTO it and consume its name, but cannot
# destroy it by being torn down themselves.

module "resource_group" {
  source   = "../_blocks/resource-group"
  name     = "${var.prefix}-rg"
  location = var.region
  tags     = var.tags
}

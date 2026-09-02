locals {
  databricks_delegation = {
    name         = "databricks-subnet-delegation"
    service_name = "Microsoft.Databricks/workspaces"
    actions = [
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
    ]
  }

  databricks_nsg_rules = {
    AllowAAD = {
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureActiveDirectory"
    }
    AllowAzureFrontDoor = {
      priority                   = 201
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureFrontDoor.Frontend"
    }
  }

  nat_gateway_id = var.nat_gateway_id != "" ? var.nat_gateway_id : null

  # Databricks subnets always get the NSG; NAT association follows the (plan-time) flag.
  associate_nat_gateway = var.enable_outbound_nat

  # Only create the private DNS zones actually consumed by an enabled private endpoint:
  #  - classic zone: workspace classic PE (enable_classic_privatelink)
  #  - dfs/blob zones: workspace classic PE OR storage external-location PE
  storage_pl_enabled = var.enable_classic_privatelink || var.enable_storage_privatelink
  dns_zones = merge(
    var.enable_classic_privatelink ? { classic = "privatelink.azuredatabricks.net" } : {},
    local.storage_pl_enabled ? {
      dfs  = "privatelink.dfs.core.windows.net"
      blob = "privatelink.blob.core.windows.net"
    } : {},
  )
}

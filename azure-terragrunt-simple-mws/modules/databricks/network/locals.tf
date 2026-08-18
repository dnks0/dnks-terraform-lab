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
  associate_nat_gateway = var.enable_nat_gateway

  # Only create the private DNS zones actually consumed by an enabled private endpoint:
  #  - backend zone: workspace backend PE (enable_backend_privatelink)
  #  - dfs/blob zones: workspace backend PE OR storage external-location PE
  storage_pl_enabled = var.enable_backend_privatelink || var.enable_external_location_privatelink
  dns_zones = merge(
    var.enable_backend_privatelink ? { backend = "privatelink.azuredatabricks.net" } : {},
    local.storage_pl_enabled ? {
      dfs  = "privatelink.dfs.core.windows.net"
      blob = "privatelink.blob.core.windows.net"
    } : {},
  )
}

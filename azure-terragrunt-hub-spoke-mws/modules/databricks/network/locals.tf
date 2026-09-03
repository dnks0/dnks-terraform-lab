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

  # Databricks serverless is exposed per region via the AzureDatabricksServerless.<Region>
  # service tag, where <Region> is Azure's canonical PascalCase region name — Azure rejects
  # any other casing. The deployment slug (var.region) is exactly the lowercase form of that
  # name, so we recover the canonical suffix by keying the list on lower(suffix). List sourced
  # from `az network list-service-tags`; regenerate it if Azure adds serverless regions. Any
  # region not in the list falls back to the (valid) non-regional AzureDatabricksServerless tag
  # so an apply never fails on an unmapped region.
  serverless_tag_suffixes = [
    "AustraliaCentral", "AustraliaCentral2", "AustraliaEast",
    "AustraliaSoutheast", "AustriaEast", "BelgiumCentral", "BrazilSouth",
    "BrazilSoutheast", "CanadaCentral", "CanadaEast", "CentralIndia",
    "CentralUS", "CentralUSEUAP", "ChileCentral", "DenmarkEast", "EastAsia",
    "EastUS", "EastUS2", "EastUS2EUAP", "EastUS3", "FranceCentral",
    "FranceSouth", "GermanyNorth", "GermanyWestCentral", "IndiaSouthCentral",
    "IndonesiaCentral", "IsraelCentral", "IsraelNorthwest", "ItalyNorth",
    "JapanEast", "JapanWest", "JioIndiaCentral", "JioIndiaWest",
    "KoreaCentral", "KoreaSouth", "MalaysiaSouth", "MalaysiaWest",
    "MexicoCentral", "NewZealandNorth", "NorthCentralUS", "NortheastUS5",
    "NorthEurope", "NorwayEast", "NorwayWest", "PolandCentral",
    "QatarCentral", "SouthAfricaNorth", "SouthAfricaWest", "SouthCentralUS",
    "SouthCentralUS2", "SoutheastAsia", "SoutheastUS", "SoutheastUS3",
    "SoutheastUS5", "SouthIndia", "SouthwestUS", "SpainCentral",
    "SwedenCentral", "SwedenSouth", "SwitzerlandNorth", "SwitzerlandWest",
    "TaiwanNorth", "TaiwanNorthwest", "UAECentral", "UAENorth", "UKSouth",
    "UKWest", "WestCentralUS", "WestEurope", "WestIndia", "WestUS",
    "WestUS2", "WestUS3",
  ]
  serverless_tag_by_region = { for s in local.serverless_tag_suffixes : lower(s) => s }
  serverless_service_tag = contains(keys(local.serverless_tag_by_region), lower(var.region)) ? (
    "AzureDatabricksServerless.${local.serverless_tag_by_region[lower(var.region)]}"
  ) : "AzureDatabricksServerless"
}

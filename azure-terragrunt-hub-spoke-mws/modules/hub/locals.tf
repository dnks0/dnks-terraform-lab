locals {
  # Azure service tags carry the region as its canonical PascalCase name; Azure rejects any
  # other casing. The deployment slug (var.region) is exactly the lowercase form, so we recover
  # the canonical suffix by keying the list on lower(suffix). List sourced from
  # `az network list-service-tags`; regenerate if Azure adds regions. Unmapped regions fall back
  # to title(var.region) so an apply degrades gracefully rather than erroring on the lookup.
  region_suffixes = [
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
  region_suffix_by_slug = { for s in local.region_suffixes : lower(s) => s }
  region_suffix = contains(keys(local.region_suffix_by_slug), lower(var.region)) ? (
    local.region_suffix_by_slug[lower(var.region)]
  ) : title(var.region)
}

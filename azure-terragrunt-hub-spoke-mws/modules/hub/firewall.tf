# Databricks egress rules for the hub firewall. Source is the hub IP group (spoke subnet CIDRs
# are added to it by hub-spoke-config). Region service tags use the canonical PascalCase suffix
# resolved in locals.tf — NOT title(var.region), which mis-cases multi-word regions (e.g.
# "westeurope" -> "Westeurope" instead of "WestEurope").
resource "azurerm_firewall_policy_rule_collection_group" "this" {
  name               = "${var.prefix}-firewall-dbx-rcg"
  firewall_policy_id = module.firewall.firewall_policy_id
  priority           = 200

  network_rule_collection {
    name     = "${var.prefix}-firewall-dbx-nrc"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "adb-storage"
      protocols             = ["TCP", "UDP"]
      source_ip_groups      = [module.ip_group.id]
      destination_addresses = ["Storage.${local.region_suffix}"]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "adb-sql"
      protocols             = ["TCP"]
      source_ip_groups      = [module.ip_group.id]
      destination_addresses = ["Sql.${local.region_suffix}"]
      destination_ports     = ["3306"]
    }

    rule {
      name                  = "adb-eventhub"
      protocols             = ["TCP"]
      source_ip_groups      = [module.ip_group.id]
      destination_addresses = ["EventHub.${local.region_suffix}"]
      destination_ports     = ["9093"]
    }
  }

  application_rule_collection {
    name     = "${var.prefix}-firewall-dbx-arc"
    priority = 101
    action   = "Allow"

    rule {
      name              = "allow-all"
      source_ip_groups  = [module.ip_group.id]
      destination_fqdns = ["*"]
      protocols {
        port = 80
        type = "Http"
      }
      protocols {
        port = "443"
        type = "Https"
      }
    }
  }
}

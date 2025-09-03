resource "azurerm_public_ip" "this" {
  name                = "${var.prefix}-firewall-pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags     = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_firewall_policy" "this" {
  name                = "${var.prefix}-firewall-ply"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags     = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_ip_group" "this" {
  name                = "${var.prefix}-firewall-ipg"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_firewall" "this" {
  name                = "${var.prefix}-firewall"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.this.id

  ip_configuration {
    name                 = "${var.prefix}-firewall-pip-config"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.this.id
  }
  tags     = var.tags
  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = []
}

resource "azurerm_firewall_policy_rule_collection_group" "this" {
  name               = "${var.prefix}-firewall-dbx-rcg"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 200

  # Define network rule collection within the rule collection group
  network_rule_collection {
    name     = "${var.prefix}-firewall-dbx-nrc"
    priority = 100
    action   = "Allow"

    # Define rules within the network rule collection
    rule {
      name                  = "adb-storage"
      protocols             = ["TCP", "UDP"]
      source_ip_groups      = [azurerm_ip_group.this.id]
      destination_addresses = [lookup(local.service_tags, "storage", "Storage")]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "adb-sql"
      protocols             = ["TCP"]
      source_ip_groups      = [azurerm_ip_group.this.id]
      destination_addresses = [lookup(local.service_tags, "sql", "Sql")]
      destination_ports     = ["3306"]
    }

    rule {
      name                  = "adb-eventhub"
      protocols             = ["TCP"]
      source_ip_groups      = [azurerm_ip_group.this.id]
      destination_addresses = [lookup(local.service_tags, "eventhub", "EventHub")]
      destination_ports     = ["9093"]
    }
  }

  # Define application rule collection within the rule collection group
  application_rule_collection {
    name     = "${var.prefix}-firewall-dbx-arc"
    priority = 101
    action   = "Allow"

    # Define rules within the application rule collection
    rule {
      name              = "allow-all"
      source_ip_groups  = [azurerm_ip_group.this.id]
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

# Generic Azure Firewall: public IP + policy + firewall. Purpose-agnostic — the Databricks
# egress rule collection group is composed on top of this block in the hub pattern module.
resource "azurerm_public_ip" "this" {
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_firewall_policy" "this" {
  name                = "${var.name}-ply"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_firewall" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.this.id

  ip_configuration {
    name                 = "${var.name}-pip-config"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.this.id
  }
  tags = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

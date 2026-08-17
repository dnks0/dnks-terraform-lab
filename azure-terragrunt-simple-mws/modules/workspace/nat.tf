resource "azurerm_nat_gateway" "this" {
  location                = var.region
  name                    = "${var.prefix}-nat"
  resource_group_name     = azurerm_resource_group.this.name
  sku_name                = "StandardV2"
  tags = var.tags
}

resource "azurerm_public_ip" "this" {
  name                = "${var.prefix}-nat-pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "StandardV2"
  tags     = var.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_nat_gateway_public_ip_association" "res-1" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.this.id
}

resource "azurerm_subnet_nat_gateway_association" "container" {
  subnet_id = azurerm_subnet.container.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

resource "azurerm_subnet_nat_gateway_association" "host" {
  subnet_id = azurerm_subnet.host.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

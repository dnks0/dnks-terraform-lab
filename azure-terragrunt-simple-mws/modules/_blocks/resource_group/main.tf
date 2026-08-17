# _blocks/resource_group — a single Azure resource group.
# Generic, purpose-agnostic. Composed by pattern modules.

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

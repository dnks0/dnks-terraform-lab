terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }

    databricks = {
      source = "databricks/databricks"
    }
  }
}

resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-rg"
  location = var.region
  tags     = var.tags
}

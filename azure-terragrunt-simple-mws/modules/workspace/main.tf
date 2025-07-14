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

# Generate a random string for dbfsnaming
resource "random_string" "this" {
  special = false
  upper   = false
  length  = 8
}

resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-rg"
  location = var.region
  tags     = var.tags
}

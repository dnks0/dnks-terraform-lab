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

provider "databricks" {
  # authentication configured via env!
  alias   = "workspace"
  host    = var.workspace_host
}

# Generate a random string for naming
resource "random_string" "this" {
  special = false
  upper   = false
  length  = 8
}

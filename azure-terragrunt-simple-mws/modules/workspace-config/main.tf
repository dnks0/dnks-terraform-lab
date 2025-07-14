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

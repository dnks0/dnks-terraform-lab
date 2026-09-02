terraform {
  required_version = ">= 1.9"
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

provider "databricks" {
  # authentication configured via env!
  alias = "workspace"
  host  = var.workspace_host
}

terraform {
  required_version = ">= 1.9"
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.122"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

provider "databricks" {
  # authentication configured via env!
  alias   = "workspace"
  host    = var.workspace_host
}

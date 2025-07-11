terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
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

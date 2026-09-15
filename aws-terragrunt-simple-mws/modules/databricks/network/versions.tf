terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    # Declared because root.hcl generates an aliased databricks provider block into
    # every unit; this module itself creates no databricks resources.
    databricks = {
      source = "databricks/databricks"
    }
  }
}

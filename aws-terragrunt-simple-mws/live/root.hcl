locals {
  prefix                            = "dnks-tg-simple-mws"
  environment                       = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals
  region                            = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  business_unit                     = read_terragrunt_config(find_in_parent_folders("business-unit.hcl")).locals

  owner                             = ""  # fill-in if required!

  databricks_account_id             = get_env("DATABRICKS_ACCOUNT_ID")
  databricks_account_client_id      = get_env("DATABRICKS_CLIENT_ID")
  databricks_account_client_secret  = get_env("DATABRICKS_CLIENT_SECRET")

  default_tags                      = merge(
    local.owner == "" ? {} : {Owner = local.owner},  # fill-in if required!
    {
      Business-Unit = local.business_unit.name
      Environment   = local.environment.name
      remove_after  = "2025-12-31"
    }
  )
}

generate "aws-provider" {
  path      = "aws-provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "aws" {
  # authentication configured via env!
  region  = "${local.region.name}"

  default_tags {
    tags = ${jsonencode(local.default_tags)}
  }

  # only these AWS account IDs may be operated on by this template
  allowed_account_ids = ["${local.environment.aws_account_id}"]
}
EOF
}

generate "dbx-mws-provider" {
  path      = "dbx-mws-provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "databricks" {
  # authentication configured via env!
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
}
EOF
}

#remote_state {
#  backend = "s3"
#  generate = {
#      path    = "backend.tf"
#      if_exists = "overwrite_terragrunt"
#  }
#
#  config = {
#      encrypt = true
#      bucket  = "${local.prefix}-dbx-shared-tf-states"
#      key     = "${path_relative_to_include()}/terraform.tfstate"
#      region  = local.region.name
#      #dynamodb_table  = "shared-terraform-locks"
#  }
#}

errors {
  # ignore block for known safe-to-ignore errors
  ignore "known-safe-errors" {
    ignorable_errors = [".*Error:.*mock.*"]
    message = "Ignoring safe warning errors related to mock output."
    signals = {
      alert_team = false
      send_notification = true
    }
  }
}

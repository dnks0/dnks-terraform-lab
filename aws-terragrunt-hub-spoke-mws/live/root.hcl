locals {
  prefix        = "dnks-tg-hub-spoke-mws"
  environment   = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals
  region        = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  business_unit = read_terragrunt_config(find_in_parent_folders("business-unit.hcl")).locals

  owner = "" # fill-in if required!

  databricks_account_id            = get_env("DATABRICKS_ACCOUNT_ID")
  databricks_account_client_id     = get_env("DATABRICKS_CLIENT_ID")
  databricks_account_client_secret = get_env("DATABRICKS_CLIENT_SECRET")

  default_tags = merge(
    local.owner == "" ? {} : { Owner = local.owner }, # fill-in if required!
    {
      Business-Unit = local.business_unit.name
      Environment   = local.environment.name
    }
  )

  # Feature flags: safe global baseline. Defaults preserve current AWS hub-spoke behavior
  # (existing on-by-default functionality stays true; reserved extension points stay false).
  # There is no enable_outbound_nat: spoke egress always goes through the hub NAT.
  feature_baseline = {
    enable_serverless_connectivity = false # current AWS state (NCC off); Azure baseline is true
    enable_network_policy          = true
    enable_classic_privatelink     = true
    enable_default_compute         = true
    disable_legacy_features        = true

    # reserved extension points (not built yet — kept false)
    enable_cmk                       = false
    enable_security_compliance_addon = false
    enable_inbound_privatelink       = false
    enable_storage_privatelink       = false # subsumed by enable_classic_privatelink on AWS
    enable_egress_firewall           = false # AWS Network Firewall in the hub (egress inspection)
  }

  # Resolution cascade (least -> most specific, later wins). Each hierarchy level may
  # optionally define a flat `features` map; any level that doesn't is simply skipped.
  # Leaves apply their own final override on top of `feature_flags`.
  feature_flags = merge(
    local.feature_baseline,
    try(local.environment.features, {}),
    try(local.region.features, {}),
    try(local.business_unit.features, {}),
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
    message          = "Ignoring safe warning errors related to mock output."
    signals = {
      alert_team        = false
      send_notification = true
    }
  }
}

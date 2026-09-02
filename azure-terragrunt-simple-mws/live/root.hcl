locals {
  prefix        = "dnks-tg-simple-mws"
  environment   = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals
  region        = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals
  business_unit = read_terragrunt_config(find_in_parent_folders("business-unit.hcl")).locals

  owner = "dominik.schuessele@databricks.com" # fill-in if required!

  databricks_account_id = get_env("DATABRICKS_ACCOUNT_ID")
  arm_client_id         = get_env("ARM_CLIENT_ID")
  arm_client_secret     = get_env("ARM_CLIENT_SECRET")
  arm_subscription_id   = get_env("ARM_SUBSCRIPTION_ID")
  arm_tenant_id         = get_env("ARM_TENANT_ID")

  default_tags = merge(
    local.owner == "" ? {} : { Owner = local.owner }, # fill-in if required!
    {
      Business-Unit = local.business_unit.name
      Environment   = local.environment.name
    }
  )

  # Feature flags: safe global baseline. Defaults preserve current behavior
  # (existing on-by-default functionality stays true; reserved extension points stay false).
  feature_baseline = {
    enable_serverless_connectivity = false
    enable_network_policy          = false
    enable_outbound_nat            = true
    enable_classic_privatelink     = true
    enable_storage_privatelink     = true
    enable_default_compute         = true
    disable_legacy_features        = true

    # reserved extension points (not built yet — kept false)
    enable_cmk                       = false
    enable_security_compliance_addon = false
    enable_inbound_privatelink       = false
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

generate "azure-provider" {
  path      = "azure-provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "azurerm" {
  # authentication configured via env!
  features {}
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
  host          = "https://accounts.azuredatabricks.net"
}
EOF
}

#remote_state {
#  backend = "azurerm"
#  generate = {
#      path    = "backend.tf"
#      if_exists = "overwrite_terragrunt"
#  }
#  config = {
#    client_id             = local.arm_client_id
#    client_secret         = local.arm_client_secret
#    subscription_id       = local.arm_subscription_id
#    tenant_id             = local.arm_tenant_id
#    resource_group_name   = "${local.prefix}-dbx-tf"        # create resource-group manually!
#    storage_account_name  = "dbxsharedtfstates"             # create storage-account manually!
#    container_name        = "terraform-states"              # create storage-container manually!
#    key                   = "${path_relative_to_include()}/terraform.tfstate"
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

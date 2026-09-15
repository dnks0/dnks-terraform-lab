resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on      = [null_resource.previous]
  create_duration = "30s"
}

resource "databricks_storage_credential" "this" {
  provider = databricks.workspace
  name     = "${var.prefix}-storage-credential"
  aws_iam_role {
    # Constructed ARN (not a resource reference) to avoid a cycle: the UC role's trust policy is
    # built from this credential's external_id.
    role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.prefix}-uc-role"
  }
}

resource "databricks_external_location" "this" {
  provider        = databricks.workspace
  name            = "${var.prefix}-external-location"
  url             = "s3://${var.bucket_name}/"
  credential_name = databricks_storage_credential.this.id
  comment         = "External location for workspace ${var.workspace_name}"
  force_destroy   = true
  depends_on = [
    module.uc_role,
    time_sleep.wait_30_seconds,
    databricks_storage_credential.this,
  ]
}

resource "databricks_catalog" "this" {
  provider       = databricks.workspace
  name           = replace(var.business_unit, "-", "_")
  comment        = "Default catalog of workspace ${var.workspace_name}"
  isolation_mode = "ISOLATED"
  storage_root   = "s3://${var.bucket_name}/"
  force_destroy  = true
  depends_on     = [databricks_storage_credential.this, databricks_external_location.this]
}

resource "databricks_schema" "this" {
  provider      = databricks.workspace
  catalog_name  = databricks_catalog.this.id
  name          = "default"
  comment       = "Default schema"
  force_destroy = true
}

resource "databricks_default_namespace_setting" "this" {
  provider = databricks.workspace
  namespace {
    value = databricks_catalog.this.name
  }
}

resource "databricks_grant" "storage-credential" {
  provider           = databricks.workspace
  storage_credential = databricks_storage_credential.this.id
  principal          = var.admin_group
  privileges         = ["ALL_PRIVILEGES", "MANAGE"]
}

resource "databricks_grant" "external-location" {
  provider          = databricks.workspace
  external_location = databricks_external_location.this.id
  principal         = var.admin_group
  privileges        = ["ALL_PRIVILEGES", "MANAGE"]
}

resource "databricks_grant" "catalog" {
  provider   = databricks.workspace
  catalog    = databricks_catalog.this.name
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

resource "databricks_grant" "schema" {
  provider   = databricks.workspace
  schema     = databricks_schema.this.id
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

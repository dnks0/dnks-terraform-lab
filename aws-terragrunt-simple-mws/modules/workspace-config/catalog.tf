resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]
  create_duration = "30s"
}

resource "databricks_storage_credential" "this" {
  provider  = databricks.workspace
  name      = "${var.prefix}-storage-credential"
  aws_iam_role {
    //cannot reference aws_iam_role directly, as it will create circular dependency
    role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.prefix}-uc-role"
  }
}

resource "databricks_external_location" "this" {
  provider        = databricks.workspace
  name            = "${var.prefix}-external-location"
  url             = "s3://${aws_s3_bucket.this.bucket}/"
  credential_name = databricks_storage_credential.this.id
  comment         = "External location for workspace ${var.workspace_name}"
  force_destroy   = true
  depends_on      = [
    aws_iam_policy_attachment.this,
    time_sleep.wait_30_seconds,
    databricks_storage_credential.this,
    aws_s3_bucket.this,
  ]
}

resource "databricks_catalog" "this" {
  name            = replace(var.business_unit, "-", "_")
  provider        = databricks.workspace
  comment         = "Default catalog of workspace ${var.workspace_name}"
  isolation_mode  = "ISOLATED"
  storage_root    = "s3://${aws_s3_bucket.this.bucket}/"
  force_destroy   = true
  depends_on      = [aws_s3_bucket.this, databricks_storage_credential.this, databricks_external_location.this]
}

resource "databricks_schema" "this" {
  provider      = databricks.workspace
  catalog_name  = databricks_catalog.this.id
  name          = "default"
  comment       = "Default schema"
  force_destroy = true
}

resource "databricks_default_namespace_setting" "this" {
  provider  = databricks.workspace
  namespace {
    value = databricks_catalog.this.name
  }
}

resource "databricks_grant" "storage-credential" {
  storage_credential   = databricks_storage_credential.this.id
  provider  = databricks.workspace
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

resource "databricks_grant" "external-location" {
  external_location   = databricks_external_location.this.id
  provider  = databricks.workspace
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

resource "databricks_grant" "catalog" {
  catalog = databricks_catalog.this.name
  provider  = databricks.workspace
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

resource "databricks_grant" "schema" {
  schema   = databricks_schema.this.id
  provider  = databricks.workspace
  principal  = var.admin_group
  privileges = ["ALL_PRIVILEGES", "MANAGE"]
}

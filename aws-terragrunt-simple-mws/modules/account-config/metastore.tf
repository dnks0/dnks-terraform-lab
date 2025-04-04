resource "databricks_metastore" "this" {
  provider      = databricks.mws
  name          = "${var.prefix}-metastore"
  storage_root  = "s3://${aws_s3_bucket.this.id}/metastore"
  owner         = databricks_group.admin_group.display_name
  region        = var.region
  force_destroy = true

  depends_on = [
    databricks_group.admin_group,
  ]
}

# databricks/storage — the Unity Catalog external-location data bucket. This is the long-lived,
# workspace-outliving data asset, kept in its own state. No databricks_mws_* or workspace-scoped
# objects live here — the UC governance (credential / external location / catalog) is in the uc
# unit, which consumes this bucket. On AWS the UC IAM role must co-locate with the storage
# credential (external_id cycle), so it lives in uc, not here.

module "bucket" {
  source        = "../../_blocks/s3-bucket"
  bucket_name   = "${var.prefix}-bucket"
  force_destroy = var.force_destroy
}

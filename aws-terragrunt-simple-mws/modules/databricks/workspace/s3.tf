# Workspace root (DBFS) bucket with the Databricks-provided bucket policy.
module "root_bucket" {
  source        = "../../_blocks/s3-bucket"
  bucket_name   = local.root_bucket_name
  force_destroy = true
  policy        = data.databricks_aws_bucket_policy.this.json
}

locals {
  # Deterministic name so the S3 endpoint policy (databricks/network) and the bucket-policy data
  # source can reference the root bucket without a dependency cycle.
  root_bucket_name = "${var.prefix}-workspace-root-bucket"
}

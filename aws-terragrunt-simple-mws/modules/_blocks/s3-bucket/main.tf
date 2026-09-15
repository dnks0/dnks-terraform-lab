# _blocks/s3-bucket — an S3 bucket with public-access block, versioning, server-side encryption
# and an optional bucket policy. Serves both the workspace root bucket (with the Databricks
# bucket policy) and the UC data bucket (no policy).

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.this]
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_status
  }
  depends_on = [aws_s3_bucket.this]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count      = var.policy == null ? 0 : 1
  bucket     = aws_s3_bucket.this.id
  policy     = var.policy
  depends_on = [aws_s3_bucket_public_access_block.this]

  lifecycle {
    ignore_changes = [policy]
  }
}

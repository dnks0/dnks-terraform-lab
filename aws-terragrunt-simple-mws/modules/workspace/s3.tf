resource "aws_s3_bucket" "this" {
  bucket        = "${var.prefix}-workspace-root-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "root" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket             = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on         = [aws_s3_bucket.this]
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
  depends_on = [aws_s3_bucket.this]
}

resource "aws_s3_bucket_policy" "this" {
  bucket      = aws_s3_bucket.this.id
  policy      = data.databricks_aws_bucket_policy.this.json
  depends_on  = [aws_s3_bucket.this]

  lifecycle {
    ignore_changes = [policy]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

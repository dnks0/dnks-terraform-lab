data "aws_availability_zones" "this" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "databricks_aws_assume_role_policy" "this" {
  external_id = var.databricks_account_id
}

data "databricks_aws_crossaccount_policy" "this" {}

data "databricks_aws_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.bucket
}

// Restrictive S3 endpoint policy:
data "aws_iam_policy_document" "s3-vpc-endpoint-policy" {
  count = 1

  statement {
    sid    = "Grant access to Workspace Root Bucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_s3_bucket.this.arn}/*",
      aws_s3_bucket.this.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = ["414351767826"]
    }
  }

  statement {
    sid    = "Grant access to Unity Catalog Workspace Bucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::${var.prefix}-bucket/*",
      "arn:aws:s3:::${var.prefix}-bucket",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:ResourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid    = "Grant access to Databricks Artifact Buckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObjectVersion",
      "s3:GetObject",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::databricks-prod-artifacts-${var.region}/*",
      "arn:aws:s3:::databricks-prod-artifacts-${var.region}",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = ["414351767826"]
    }
  }

  statement {
    sid    = "Grant access to Databricks System Tables Bucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObjectVersion",
      "s3:GetObject",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::system-tables-prod-${var.region}-uc-metastore-bucket/*",
      "arn:aws:s3:::system-tables-prod-${var.region}-uc-metastore-bucket"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = ["414351767826"]
    }
  }

  statement {
    sid    = "Grant access to Databricks Sample Data Bucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObjectVersion",
      "s3:GetObject",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::databricks-datasets-${var.region_bucket_name[var.region]}/*",
      "arn:aws:s3:::databricks-datasets-${var.region_bucket_name[var.region]}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = ["414351767826"]
    }
  }

  statement {
    sid    = "Grant access to Databricks Log Bucket"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::databricks-prod-storage-${var.region_bucket_name[var.region]}/*",
      "arn:aws:s3:::databricks-prod-storage-${var.region_bucket_name[var.region]}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = ["414351767826"]
    }
  }
}

// Restrictive STS endpoint policy:
data "aws_iam_policy_document" "sts-vpc-endpoint-policy" {
  count = 1
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:GetAccessKeyInfo",
      "sts:GetSessionToken",
      "sts:DecodeAuthorizationMessage",
      "sts:TagSession"
    ]
    effect    = "Allow"
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:GetSessionToken",
      "sts:TagSession"
    ]
    effect    = "Allow"
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::414351767826:user/databricks-datasets-readonly-user-prod",
        "414351767826"
      ]
    }
  }
}

// Restrictive Kinesis endpoint policy:
data "aws_iam_policy_document" "kinesis-vpc-endpoint-policy" {
  count = 1
  statement {
    actions = [
      "kinesis:PutRecord",
      "kinesis:PutRecords",
      "kinesis:DescribeStream"
    ]
    effect    = "Allow"
    resources = ["arn:aws:kinesis:${var.region}:414351767826:stream/*"]

    principals {
      type        = "AWS"
      identifiers = ["414351767826"]
    }
  }
}

data "aws_caller_identity" "current" {}

# Restrictive S3 endpoint policy. The workspace root bucket lives in the workspace unit, so it
# is referenced here by its (deterministic) ARN string rather than by resource.
data "aws_iam_policy_document" "s3_endpoint" {
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
      "arn:aws:s3:::${var.prefix}-workspace-root-bucket/*",
      "arn:aws:s3:::${var.prefix}-workspace-root-bucket"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [local.databricks_control_plane_account_id]
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
      values   = [local.databricks_control_plane_account_id]
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
      values   = [local.databricks_control_plane_account_id]
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
      values   = [local.databricks_control_plane_account_id]
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
      values   = [local.databricks_control_plane_account_id]
    }
  }
}

# Restrictive STS endpoint policy.
data "aws_iam_policy_document" "sts_endpoint" {
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
      identifiers = [data.aws_caller_identity.current.account_id]
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
        "arn:aws:iam::${local.databricks_control_plane_account_id}:user/databricks-datasets-readonly-user-prod",
        local.databricks_control_plane_account_id
      ]
    }
  }
}

# Restrictive Kinesis endpoint policy.
data "aws_iam_policy_document" "kinesis_endpoint" {
  statement {
    actions = [
      "kinesis:PutRecord",
      "kinesis:PutRecords",
      "kinesis:DescribeStream"
    ]
    effect    = "Allow"
    resources = ["arn:aws:kinesis:${var.region}:${local.databricks_control_plane_account_id}:stream/*"]

    principals {
      type        = "AWS"
      identifiers = [local.databricks_control_plane_account_id]
    }
  }
}

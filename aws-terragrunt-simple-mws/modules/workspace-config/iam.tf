resource "aws_iam_policy" "this" {
  name   = "${var.prefix}-uc-policy"
  policy = data.databricks_aws_unity_catalog_policy.this.json
}

resource "aws_iam_role" "this" {
  name               = "${var.prefix}-uc-role"
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.this.json
  tags               = var.tags
}

resource "aws_iam_policy_attachment" "this" {
  name       = "${var.prefix}-uc-policy-attm"
  roles      = [aws_iam_role.this.name]
  policy_arn = aws_iam_policy.this.arn
}

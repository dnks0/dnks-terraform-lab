# _blocks/iam-role — an IAM role with an optional inline policy and/or an optional customer
# managed policy (created here and attached). Both are optional so the block serves the
# cross-account role (inline crossaccount policy) and the UC role (managed UC policy) alike.

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = var.assume_role_policy

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_iam_role_policy" "this" {
  count  = var.inline_policy == null ? 0 : 1
  name   = var.inline_policy_name
  role   = aws_iam_role.this.id
  policy = var.inline_policy
}

resource "aws_iam_policy" "this" {
  count  = var.managed_policy == null ? 0 : 1
  name   = var.managed_policy_name
  policy = var.managed_policy
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.managed_policy == null ? 0 : 1
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this[0].arn
}

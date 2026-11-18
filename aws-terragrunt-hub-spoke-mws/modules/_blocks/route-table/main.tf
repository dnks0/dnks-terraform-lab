# _blocks/route-table — a route table, its routes, and its subnet associations.
# These are 1:1 with the route table, so they live together as one atomic unit.

resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    ignore_changes = [tags]
  }
}

# Each route sets exactly one target; the unused target(s) are null (optional()).
resource "aws_route" "this" {
  for_each = { for r in var.routes : r.cidr_block => r }

  route_table_id         = aws_route_table.this.id
  destination_cidr_block = each.value.cidr_block
  gateway_id             = each.value.gateway_id
  nat_gateway_id         = each.value.nat_gateway_id
}

# Associations count off the length of subnet_ids (known at plan time), not off IDs that
# may be unknown until apply — gating on the IDs would raise "Invalid count argument".
resource "aws_route_table_association" "this" {
  count          = length(var.subnet_ids)
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = aws_route_table.this.id
}

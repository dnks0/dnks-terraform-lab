# _blocks/transit-gateway — a single Transit Gateway. Attachments associate with and propagate
# to its default route table, so spoke CIDRs are learned automatically.

resource "aws_ec2_transit_gateway" "this" {
  description                     = var.description
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    ignore_changes = [tags]
  }
}

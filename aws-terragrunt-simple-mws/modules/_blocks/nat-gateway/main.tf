# _blocks/nat-gateway — a NAT gateway with its Elastic IP.
# Placed in a public subnet by the caller. The default route to this gateway is owned by
# the route-table block (1:1 with each private route table).

resource "aws_eip" "this" {
  domain = "vpc"

  tags = merge(var.tags, { Name = var.eip_name })

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = var.subnet_id

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    ignore_changes = [tags]
  }
}

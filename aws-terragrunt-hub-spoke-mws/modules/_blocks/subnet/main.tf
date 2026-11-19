# _blocks/subnet — a single subnet.
# Generic, purpose-agnostic. Route-table associations are owned by the route-table block;
# security groups attach to resources (ENIs), not subnets, on AWS.

resource "aws_subnet" "this" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    ignore_changes = [tags]
  }
}

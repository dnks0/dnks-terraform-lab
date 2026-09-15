# _blocks/vpc-endpoint — a single VPC endpoint (Gateway or Interface).
# Gateway endpoints attach to route tables; Interface endpoints attach to subnets + security
# groups (with optional private DNS). The unused set of arguments is null for the other type.

resource "aws_vpc_endpoint" "this" {
  vpc_id            = var.vpc_id
  service_name      = var.service_name
  vpc_endpoint_type = var.endpoint_type

  # Interface-only
  subnet_ids          = var.endpoint_type == "Interface" ? var.subnet_ids : null
  security_group_ids  = var.endpoint_type == "Interface" ? var.security_group_ids : null
  private_dns_enabled = var.endpoint_type == "Interface" ? var.private_dns_enabled : null

  # Gateway-only
  route_table_ids = var.endpoint_type == "Gateway" ? var.route_table_ids : null

  policy = var.policy

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    ignore_changes = [tags]
  }
}

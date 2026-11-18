# _blocks/transit-gateway-attachment — attaches one VPC to a Transit Gateway through the given
# subnets (one per AZ), associated with and propagating to the TGW default route table.

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
  dns_support        = "enable"

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = merge(var.tags, { Name = var.name, Purpose = var.purpose })

  lifecycle {
    ignore_changes = [tags]
  }
}

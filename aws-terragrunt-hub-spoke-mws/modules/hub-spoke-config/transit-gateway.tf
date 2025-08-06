resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  subnet_ids         = var.spoke_tgw_subnet_ids
  transit_gateway_id = var.hub_transit_gateway_id
  vpc_id             = var.spoke_vpc_id
  dns_support        = "enable"

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  tags = merge(var.tags, {
    Name    = "${var.prefix}-tgw-atm"
    Purpose = "Transit Gateway Attachment - Spoke VPC"
  })
}

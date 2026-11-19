# hub-spoke-config — connects one spoke to the hub: attaches the spoke VPC to the hub Transit
# Gateway and adds the routes (routes.tf). Always on, no feature flag. Routes are standalone
# aws_route resources, so they coexist with the route tables managed by _blocks/route-table.

module "spoke_attachment" {
  source             = "../_blocks/transit-gateway-attachment"
  name               = "${var.prefix}-tgw-atm"
  purpose            = "Transit Gateway Attachment - Spoke VPC"
  vpc_id             = var.spoke_vpc_id
  subnet_ids         = var.spoke_tgw_subnet_ids
  transit_gateway_id = var.hub_transit_gateway_id
  tags               = var.tags
}

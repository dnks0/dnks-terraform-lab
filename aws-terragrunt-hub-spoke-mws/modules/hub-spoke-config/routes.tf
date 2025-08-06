resource "aws_route" "spoke-to-tgw-outbound" {
  for_each               = toset(var.spoke_private_route_table_ids)
  route_table_id         = each.key
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.hub_transit_gateway_id
}

resource "aws_route" "spoke-to-tgw-inbound" {
  for_each               = toset(var.hub_private_route_table_ids)
  route_table_id         = each.key
  destination_cidr_block = var.spoke_vpc_cidr
  transit_gateway_id     = var.hub_transit_gateway_id
}

resource "aws_route" "spoke-nat-to-tgw-inbound" {
  for_each               = toset(var.hub_public_route_table_ids)
  route_table_id         = each.key
  destination_cidr_block = var.spoke_vpc_cidr
  transit_gateway_id     = var.hub_transit_gateway_id
}

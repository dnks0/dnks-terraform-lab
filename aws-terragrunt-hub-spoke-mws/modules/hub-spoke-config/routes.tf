# for_each keys are list indexes: route table IDs come from dependency outputs and can be
# unknown at plan time, but the list lengths are known.

# Spoke egress: 0.0.0.0/0 from each spoke private route table → TGW → hub → NAT.
resource "aws_route" "spoke-to-tgw-outbound" {
  for_each               = { for i, id in var.spoke_private_route_table_ids : tostring(i) => id }
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.hub_transit_gateway_id
  depends_on             = [module.spoke_attachment]
}

# Return path inside the hub: spoke CIDR from the hub private (TGW) route tables → TGW.
resource "aws_route" "spoke-to-tgw-inbound" {
  for_each               = { for i, id in var.hub_private_route_table_ids : tostring(i) => id }
  route_table_id         = each.value
  destination_cidr_block = var.spoke_vpc_cidr
  transit_gateway_id     = var.hub_transit_gateway_id
  depends_on             = [module.spoke_attachment]
}

# Return path for NAT'd traffic: spoke CIDR from the hub public route table(s) → TGW.
resource "aws_route" "spoke-nat-to-tgw-inbound" {
  for_each               = { for i, id in var.hub_public_route_table_ids : tostring(i) => id }
  route_table_id         = each.value
  destination_cidr_block = var.spoke_vpc_cidr
  transit_gateway_id     = var.hub_transit_gateway_id
  depends_on             = [module.spoke_attachment]
}

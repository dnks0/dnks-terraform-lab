# hub — shared central network for the hub-spoke topology. Owns the hub VPC with its internet
# gateway, public subnets (one NAT gateway each, shared public route table → IGW), private
# subnets that host the Transit Gateway attachment (per-AZ route table → that AZ's NAT), the
# Transit Gateway, the hub attachment, and the TGW default route 0.0.0.0/0 → hub. Spokes attach
# in hub-spoke-config, which also adds the return routes for the spoke CIDR.
#
# Derived values (availability zones) live in locals.tf; data sources in data.tf.

module "vpc" {
  source = "../_blocks/vpc"
  name   = "${var.prefix}-vpc"
  cidr   = var.vpc_cidr
  tags   = var.tags
}

# --- Public side: NAT gateways + route to the internet gateway ---
module "public_subnet" {
  source                  = "../_blocks/subnet"
  count                   = length(var.public_subnets_cidr)
  name                    = "${var.prefix}-public-snt-${local.azs[count.index]}"
  vpc_id                  = module.vpc.id
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = var.tags
}

module "nat" {
  source     = "../_blocks/nat-gateway"
  count      = length(var.public_subnets_cidr)
  name       = "${var.prefix}-nat-${local.azs[count.index]}"
  eip_name   = "${var.prefix}-nat-eip-${local.azs[count.index]}"
  subnet_id  = module.public_subnet[count.index].id
  tags       = var.tags
  depends_on = [module.vpc]
}

module "public_rt" {
  source     = "../_blocks/route-table"
  name       = "${var.prefix}-public-rt"
  vpc_id     = module.vpc.id
  subnet_ids = module.public_subnet[*].id
  routes     = [{ cidr_block = "0.0.0.0/0", gateway_id = module.vpc.igw_id }]
  tags       = var.tags
}

# --- Private side: Transit Gateway attachment subnets, per-AZ route to that AZ's NAT ---
module "private_subnet" {
  source            = "../_blocks/subnet"
  count             = length(var.private_subnets_cidr)
  name              = "${var.prefix}-private-snt-${local.azs[count.index]}"
  vpc_id            = module.vpc.id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = local.azs[count.index]
  tags              = var.tags
}

module "private_rt" {
  source     = "../_blocks/route-table"
  count      = length(var.private_subnets_cidr)
  name       = "${var.prefix}-private-rt-${local.azs[count.index]}"
  vpc_id     = module.vpc.id
  subnet_ids = [module.private_subnet[count.index].id]
  routes     = [{ cidr_block = "0.0.0.0/0", nat_gateway_id = module.nat[count.index].id }]
  tags       = var.tags
}

# --- Transit Gateway ---
module "transit_gateway" {
  source = "../_blocks/transit-gateway"
  name   = "${var.prefix}-transit-gateway"
  tags   = var.tags
}

module "hub_attachment" {
  source             = "../_blocks/transit-gateway-attachment"
  name               = "${var.prefix}-tgw-atm"
  purpose            = "Transit Gateway Attachment - Hub VPC"
  vpc_id             = module.vpc.id
  subnet_ids         = module.private_subnet[*].id
  transit_gateway_id = module.transit_gateway.id
  tags               = var.tags
}

# Everything the spokes send to the TGW that isn't another attached VPC goes to the hub (→ NAT).
resource "aws_ec2_transit_gateway_route" "default_to_hub" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.hub_attachment.id
  transit_gateway_route_table_id = module.transit_gateway.association_default_route_table_id
}

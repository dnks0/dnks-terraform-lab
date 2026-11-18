# network — generic BU landing-zone network (no Databricks knowledge).
# Owns the VPC + internet gateway, the public subnets that host the NAT gateways, an optional
# per-AZ NAT gateway set (one per public subnet), a shared public route table, and any generic
# extra subnets. The Databricks data-plane + privatelink subnets, their routing and the security
# groups live in the databricks/network module, which consumes this module's outputs
# (vpc_id, nat_gateway_ids, azs).
#
# Derived values (availability zones) live in locals.tf; data sources in data.tf.

module "vpc" {
  source = "../_blocks/vpc"
  name   = "${var.prefix}-vpc"
  cidr   = var.vpc_cidr
  tags   = var.tags
}

# Public subnets host the NAT gateways and route to the internet gateway.
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

# One NAT gateway per AZ (matches the current one_nat_gateway_per_az topology). Gated on
# enable_outbound_nat; the private route tables (databricks/network) route to these.
module "nat" {
  source     = "../_blocks/nat-gateway"
  count      = var.enable_outbound_nat ? length(var.public_subnets_cidr) : 0
  name       = "${var.prefix}-nat-${local.azs[count.index]}"
  eip_name   = "${var.prefix}-nat-eip-${local.azs[count.index]}"
  subnet_id  = module.public_subnet[count.index].id
  tags       = var.tags
  depends_on = [module.vpc]
}

# Single public route table shared by all public subnets: default route to the IGW.
module "public_rt" {
  source     = "../_blocks/route-table"
  name       = "${var.prefix}-public-rt"
  vpc_id     = module.vpc.id
  subnet_ids = module.public_subnet[*].id
  routes     = [{ cidr_block = "0.0.0.0/0", gateway_id = module.vpc.igw_id }]
  tags       = var.tags
}

# Generic (non-Databricks) subnets for other workloads sharing this VPC.
module "extra_subnet" {
  source            = "../_blocks/subnet"
  for_each          = var.extra_subnets
  name              = "${var.prefix}-${each.key}-snt"
  vpc_id            = module.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags              = var.tags
}

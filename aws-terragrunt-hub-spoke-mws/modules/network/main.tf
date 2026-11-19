# network — generic spoke network for the hub-spoke topology (no Databricks knowledge).
# Owns the spoke VPC (no internet gateway, no NAT: all egress goes through the hub), one
# Transit Gateway attachment subnet per AZ, and any generic extra subnets. The Databricks
# data-plane + privatelink subnets, their route tables and the security groups live in the
# databricks/network module. hub-spoke-config attaches the TGW subnets and adds the routes.
#
# Derived values (availability zones) live in locals.tf; data sources in data.tf.

module "vpc" {
  source     = "../_blocks/vpc"
  name       = "${var.prefix}-vpc"
  cidr       = var.vpc_cidr
  create_igw = false
  tags       = var.tags
}

# Transit Gateway attachment subnets, one per AZ. No route table association: the attachment's
# network interfaces only need the VPC-local route.
module "tgw_subnet" {
  source            = "../_blocks/subnet"
  count             = length(var.tgw_subnets_cidr)
  name              = "${var.prefix}-tgw-private-snt-${local.azs[count.index]}"
  vpc_id            = module.vpc.id
  cidr_block        = var.tgw_subnets_cidr[count.index]
  availability_zone = local.azs[count.index]
  tags              = var.tags
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

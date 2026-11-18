# databricks/network — the AWS-native network resources Databricks requires beyond the generic
# spoke VPC: the workspace + privatelink security groups, the private (data-plane) and intra
# (privatelink) subnets, their route tables, and all Databricks VPC endpoints (S3 gateway +
# STS/Kinesis data-plane + backend_rest/relay control-plane). It consumes vpc_id + azs from the
# network unit and outputs network_configuration + the security-group and backend endpoint IDs
# for the workspace unit. The private route tables start without a default route: egress is
# added by hub-spoke-config (0.0.0.0/0 → Transit Gateway → hub NAT).
# No databricks_mws_* registration objects live here — those are in the workspace unit.
#
# SG rules live in locals.tf; endpoint policies in data.tf.

# --- Security groups ---
module "workspace_sg" {
  source        = "../../_blocks/security-group"
  name          = "${var.prefix}-sg"
  description   = "Databricks workspace security group"
  vpc_id        = var.vpc_id
  ingress_rules = local.workspace_sg_ingress
  egress_rules  = local.workspace_sg_egress
  tags          = var.tags
}

module "privatelink_sg" {
  source        = "../../_blocks/security-group"
  count         = var.enable_classic_privatelink ? 1 : 0
  name          = "${var.prefix}-pl-sg"
  description   = "Databricks PrivateLink endpoint security group"
  vpc_id        = var.vpc_id
  ingress_rules = local.privatelink_sg_ingress
  tags          = var.tags
}

# --- Databricks data-plane + privatelink subnets (placed in the AZs owned by the network unit) ---
module "private_subnet" {
  source            = "../../_blocks/subnet"
  count             = length(var.private_subnets_cidr)
  name              = "${var.prefix}-private-snt-${var.azs[count.index]}"
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = var.azs[count.index]
  tags              = var.tags
}

module "intra_subnet" {
  source            = "../../_blocks/subnet"
  count             = length(var.privatelink_subnets_cidr)
  name              = "${var.prefix}-privatelink-${var.azs[count.index]}"
  vpc_id            = var.vpc_id
  cidr_block        = var.privatelink_subnets_cidr[count.index]
  availability_zone = var.azs[count.index]
  tags              = var.tags
}

# --- Routing: per-AZ private RTs (default route added by hub-spoke-config); intra RT is local-only ---
module "private_rt" {
  source     = "../../_blocks/route-table"
  count      = length(var.private_subnets_cidr)
  name       = "${var.prefix}-private-rt-${var.azs[count.index]}"
  vpc_id     = var.vpc_id
  subnet_ids = [module.private_subnet[count.index].id]
  routes     = []
  tags       = var.tags
}

module "intra_rt" {
  source     = "../../_blocks/route-table"
  name       = "${var.prefix}-privatelink-rt"
  vpc_id     = var.vpc_id
  subnet_ids = module.intra_subnet[*].id
  routes     = []
  tags       = var.tags
}

# --- VPC endpoints (all gated on enable_classic_privatelink) ---
# S3 gateway endpoint on the private route tables (data-plane egress to S3).
module "s3_endpoint" {
  source          = "../../_blocks/vpc-endpoint"
  count           = var.enable_classic_privatelink ? 1 : 0
  name            = "${var.prefix}-s3"
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.${var.region}.s3"
  endpoint_type   = "Gateway"
  route_table_ids = module.private_rt[*].id
  policy          = data.aws_iam_policy_document.s3_endpoint.json
  tags            = var.tags
}

module "sts_endpoint" {
  source              = "../../_blocks/vpc-endpoint"
  count               = var.enable_classic_privatelink ? 1 : 0
  name                = "${var.prefix}-sts"
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.sts"
  endpoint_type       = "Interface"
  subnet_ids          = module.intra_subnet[*].id
  security_group_ids  = [module.privatelink_sg[0].id]
  private_dns_enabled = true
  policy              = data.aws_iam_policy_document.sts_endpoint.json
  tags                = var.tags
}

module "kinesis_endpoint" {
  source              = "../../_blocks/vpc-endpoint"
  count               = var.enable_classic_privatelink ? 1 : 0
  name                = "${var.prefix}-kinesis"
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.kinesis-streams"
  endpoint_type       = "Interface"
  subnet_ids          = module.intra_subnet[*].id
  security_group_ids  = [module.privatelink_sg[0].id]
  private_dns_enabled = true
  policy              = data.aws_iam_policy_document.kinesis_endpoint.json
  tags                = var.tags
}

# Backend PrivateLink endpoints (control plane): REST API + secure cluster connectivity relay.
module "backend_rest_endpoint" {
  source              = "../../_blocks/vpc-endpoint"
  count               = var.enable_classic_privatelink ? 1 : 0
  name                = "${var.prefix}-backend-rest"
  vpc_id              = var.vpc_id
  service_name        = var.backend_rest_vpc_endpoint_service_names[var.region]
  endpoint_type       = "Interface"
  subnet_ids          = module.intra_subnet[*].id
  security_group_ids  = [module.privatelink_sg[0].id]
  private_dns_enabled = true
  tags                = var.tags
}

module "backend_relay_endpoint" {
  source              = "../../_blocks/vpc-endpoint"
  count               = var.enable_classic_privatelink ? 1 : 0
  name                = "${var.prefix}-backend-relay"
  vpc_id              = var.vpc_id
  service_name        = var.backend_relay_vpc_endpoint_service_names[var.region]
  endpoint_type       = "Interface"
  subnet_ids          = module.intra_subnet[*].id
  security_group_ids  = [module.privatelink_sg[0].id]
  private_dns_enabled = true
  tags                = var.tags
}

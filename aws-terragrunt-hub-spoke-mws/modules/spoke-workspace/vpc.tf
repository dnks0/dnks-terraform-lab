module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  count = 1

  name = "${var.prefix}-vpc"
  cidr = var.vpc_cidr
  azs  = local.availability_zones

  enable_dns_hostnames   = true
  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false
  create_igw             = false

  private_subnet_names = [for az in local.availability_zones : format("%s-private-snt-%s", var.prefix, az)]
  private_subnets      = var.private_subnets_cidr

  intra_subnet_names = [for az in local.availability_zones : format("%s-privatelink-%s", var.prefix, az)]
  intra_subnets      = var.privatelink_subnets_cidr

}

resource "aws_subnet" "this" {
  for_each                = { for idx, az in local.availability_zones: idx => az }
  vpc_id                  = module.vpc[0].vpc_id
  cidr_block              = var.tgw_subnets_cidr[each.key]
  availability_zone       = each.value
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${var.prefix}-tgw-private-snt-${each.value}"
  })
}

resource "aws_security_group" "this" {
  count = 1

  vpc_id     = module.vpc[0].vpc_id
  depends_on = [module.vpc]

  dynamic "ingress" {
    for_each = ["tcp", "udp"]
    content {
      description = "Databricks - Workspace SG - Internode Communication"
      from_port   = 0
      to_port     = 65535
      protocol    = ingress.value
      self        = true
    }
  }

  dynamic "egress" {
    for_each = ["tcp", "udp"]
    content {
      description = "Databricks - Workspace SG - Internode Communication"
      from_port   = 0
      to_port     = 65535
      protocol    = egress.value
      self        = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_ports
    content {
      description = "Databricks - Workspace SG - REST (443), Secure Cluster Connectivity (2443/6666), Compute Plane to Control Plane Internal Calls (8443), Unity Catalog Logging and Lineage Data Streaming (8444), Future Extendability (8445-8451)"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-sg"
    }
  )
}



module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  count = 1

  name = "${var.prefix}-vpc"
  cidr = var.vpc_cidr
  azs  = local.availability_zones

  enable_dns_hostnames   = true
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  create_igw             = true

  private_subnet_names = [for az in local.availability_zones : format("%s-private-snt-%s", var.prefix, az)]
  private_subnets      = var.private_subnets_cidr

  public_subnet_names =[for az in local.availability_zones : format("%s-public-snt-%s", var.prefix, az)]
  public_subnets      = var.public_subnets_cidr

}

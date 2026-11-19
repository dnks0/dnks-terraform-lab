locals {
  # Pin subnet placement to the first N availability zones, N = number of public subnet CIDRs.
  azs = slice(data.aws_availability_zones.this.names, 0, length(var.public_subnets_cidr))
}

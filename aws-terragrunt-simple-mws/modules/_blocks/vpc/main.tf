# _blocks/vpc — a single VPC and its internet gateway.
# Generic, purpose-agnostic. Subnets / route tables / NAT / security groups are separate blocks.

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_internet_gateway" "this" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-igw" })

  lifecycle {
    ignore_changes = [tags]
  }
}

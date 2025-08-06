// Security group for privatelink
resource "aws_security_group" "privatelink" {
  count   = 1
  vpc_id  = module.vpc[0].vpc_id

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - REST API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.this[0].id]
  }

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - Secure Cluster Connectivity"
    from_port       = 6666
    to_port         = 6666
    protocol        = "tcp"
    security_groups = [aws_security_group.this[0].id]
  }

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - Secure Cluster Connectivity - Compliance Security Profile"
    from_port       = 2443
    to_port         = 2443
    protocol        = "tcp"
    security_groups = [aws_security_group.this[0].id]
  }

  ingress {
    description     = "Databricks - Internal calls from the Databricks compute plane to the Databricks control plane API"
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [aws_security_group.this[0].id]
  }

  ingress {
    description     = "Databricks - Unity Catalog logging and lineage data streaming into Databricks"
    from_port       = 8444
    to_port         = 8444
    protocol        = "tcp"
    security_groups = [aws_security_group.this[0].id]
  }

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - Future Extendability"
    from_port       = 8445
    to_port         = 8451
    protocol        = "tcp"
    security_groups = [aws_security_group.this[0].id]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-pl-sg"
    }
  )
}

module "vpc_endpoints" {
  count   = 1
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id             = module.vpc[0].vpc_id
  security_group_ids = [aws_security_group.privatelink[0].id]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc[0].private_route_table_ids
      policy          = data.aws_iam_policy_document.s3-vpc-endpoint-policy[0].json
      tags = merge(
        var.tags,
        {
          Name        = "${var.prefix}-s3"
        }
      )
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = module.vpc[0].intra_subnets
      policy              = data.aws_iam_policy_document.sts-vpc-endpoint-policy[0].json
      tags = merge(
        var.tags,
        {
          Name            = "${var.prefix}-sts"
        }
      )
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = module.vpc[0].intra_subnets
      policy              = data.aws_iam_policy_document.kinesis-vpc-endpoint-policy[0].json
      tags = merge(
        var.tags,
        {
          Name            = "${var.prefix}-kinesis"
        }
      )
    }
  }
}

resource "aws_vpc_endpoint" "backend_rest" {
  vpc_id              = module.vpc[0].vpc_id
  service_name        = var.backend_rest_vpc_endpoint_service_names[var.region]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink[0].id]
  subnet_ids          = module.vpc[0].intra_subnets
  private_dns_enabled = true
  depends_on          = [module.vpc.vpc_id]
  tags = merge(
    var.tags,
    {
      Name    = "${var.prefix}-backend-rest"
    }
  )
}

// Databricks SCC endpoint - skipped in custom operation mode
resource "aws_vpc_endpoint" "backend_relay" {
  vpc_id              = module.vpc[0].vpc_id
  service_name        = var.backend_relay_vpc_endpoint_service_names[var.region]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink[0].id]
  subnet_ids          = module.vpc[0].intra_subnets
  private_dns_enabled = true
  depends_on          = [module.vpc.vpc_id]
  tags = merge(
    var.tags,
    {
      Name    = "${var.prefix}-backend-relay"
    }
  )
}

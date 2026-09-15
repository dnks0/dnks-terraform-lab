# _blocks/security-group — a security group and its ingress/egress rules.
# Rules are passed as maps of rule objects; each rule sets its source via self / security_groups
# / cidr_blocks (additive, matching the inline aws_security_group rule semantics). Omitting all
# egress rules leaves the group with no egress (AWS's default allow-all egress is revoked),
# matching the hand-written behaviour this replaces.

resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      self            = ingress.value.self
      security_groups = ingress.value.security_groups
      cidr_blocks     = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description     = egress.value.description
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      self            = egress.value.self
      security_groups = egress.value.security_groups
      cidr_blocks     = egress.value.cidr_blocks
    }
  }

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    ignore_changes = [tags]
  }
}

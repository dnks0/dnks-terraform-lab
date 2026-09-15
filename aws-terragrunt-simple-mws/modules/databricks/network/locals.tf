locals {
  # Databricks AWS control-plane account (owns the artifact / dataset / log / system-tables
  # buckets and the PrivateLink services). Commercial (non-GovCloud) value.
  databricks_control_plane_account_id = "414351767826"

  # Workspace SG: internode all-ports (tcp + udp, self) on ingress and egress, plus egress to
  # the Databricks control/relay/UC ports on 0.0.0.0/0.
  workspace_sg_ingress = {
    internode-tcp = { description = "Databricks - Workspace SG - Internode Communication", from_port = 0, to_port = 65535, protocol = "tcp", self = true }
    internode-udp = { description = "Databricks - Workspace SG - Internode Communication", from_port = 0, to_port = 65535, protocol = "udp", self = true }
  }

  workspace_sg_egress = merge(
    {
      internode-tcp = { description = "Databricks - Workspace SG - Internode Communication", from_port = 0, to_port = 65535, protocol = "tcp", self = true }
      internode-udp = { description = "Databricks - Workspace SG - Internode Communication", from_port = 0, to_port = 65535, protocol = "udp", self = true }
    },
    {
      for port in var.sg_egress_ports : "egress-${port}" => {
        description = "Databricks - Workspace SG - REST (443), SCC (2443/6666), CP internal (8443), UC logging/lineage (8444), future (8445-8451)"
        from_port   = tonumber(port)
        to_port     = tonumber(port)
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
  )

  # PrivateLink endpoint SG: inbound from the workspace SG on the control-plane ports.
  privatelink_sg_ingress = {
    rest-443 = { description = "Databricks - PrivateLink Endpoint SG - REST API", from_port = 443, to_port = 443, protocol = "tcp", security_groups = [module.workspace_sg.id] }
    scc-6666 = { description = "Databricks - PrivateLink Endpoint SG - Secure Cluster Connectivity", from_port = 6666, to_port = 6666, protocol = "tcp", security_groups = [module.workspace_sg.id] }
    scc-2443 = { description = "Databricks - PrivateLink Endpoint SG - SCC (Compliance Security Profile)", from_port = 2443, to_port = 2443, protocol = "tcp", security_groups = [module.workspace_sg.id] }
    cp-8443  = { description = "Databricks - Internal calls from the compute plane to the control plane API", from_port = 8443, to_port = 8443, protocol = "tcp", security_groups = [module.workspace_sg.id] }
    uc-8444  = { description = "Databricks - Unity Catalog logging and lineage data streaming", from_port = 8444, to_port = 8444, protocol = "tcp", security_groups = [module.workspace_sg.id] }
    future   = { description = "Databricks - PrivateLink Endpoint SG - Future Extendability", from_port = 8445, to_port = 8451, protocol = "tcp", security_groups = [module.workspace_sg.id] }
  }

  # Per-AZ private route table routes: default route to that AZ's NAT gateway when NAT is
  # enabled, otherwise no default route (local-only).
  private_rt_routes = [
    for i in range(length(var.private_subnets_cidr)) :
    var.enable_outbound_nat ? [{ cidr_block = "0.0.0.0/0", gateway_id = null, nat_gateway_id = var.nat_gateway_ids[i] }] : []
  ]
}

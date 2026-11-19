# Typed network wiring consumed by the workspace unit (BYO-network ready). The workspace builds
# databricks_mws_networks / mws_vpc_endpoint / PAS from these.
output "network_configuration" {
  description = "Network wiring for the Databricks workspace registration"
  value = {
    vpc_id                  = var.vpc_id
    private_subnet_ids      = module.private_subnet[*].id
    intra_subnet_ids        = module.intra_subnet[*].id
    private_route_table_ids = module.private_rt[*].id
  }
}

output "workspace_security_group_id" {
  description = "ID of the Databricks workspace security group (for databricks_mws_networks)"
  value       = module.workspace_sg.id
}

# Empty string when classic PrivateLink is disabled — stable output shape.
output "backend_rest_endpoint_id" {
  description = "AWS VPC endpoint ID for the backend REST endpoint; \"\" when PrivateLink disabled"
  value       = var.enable_classic_privatelink ? module.backend_rest_endpoint[0].id : ""
}

output "backend_relay_endpoint_id" {
  description = "AWS VPC endpoint ID for the backend relay endpoint; \"\" when PrivateLink disabled"
  value       = var.enable_classic_privatelink ? module.backend_relay_endpoint[0].id : ""
}

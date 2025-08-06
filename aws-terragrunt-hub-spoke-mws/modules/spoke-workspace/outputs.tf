output "workspace_id" {
  value = databricks_mws_workspaces.this.workspace_id
}

output "workspace_host" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "workspace_name" {
  value = databricks_mws_workspaces.this.workspace_name
}

output "vpc_id" {
  value = module.vpc[0].vpc_id
}

output "vpc_cidr" {
  value = module.vpc[0].vpc_cidr_block
}

output "tgw_subnet_ids" {
  value = values(aws_subnet.this).*.id
}

output "private_route_table_ids" {
  value = module.vpc[0].private_route_table_ids
}

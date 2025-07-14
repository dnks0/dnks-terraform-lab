output "metastore_id" {
  value = databricks_metastore.this.id
}

output "account_admin_group_id" {
  value = databricks_group.admin_group.id
}

output "account_admin_group_name" {
  value = databricks_group.admin_group.display_name
}

output "network_connectivity_configuration_id" {
  value = length(databricks_mws_network_connectivity_config.this) > 0 ? databricks_mws_network_connectivity_config.this[0].network_connectivity_config_id : ""
}

output "network_policy_id" {
  value = databricks_account_network_policy.this.network_policy_id
}

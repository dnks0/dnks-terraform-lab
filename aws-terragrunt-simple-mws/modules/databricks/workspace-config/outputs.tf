# Empty string when default compute is disabled — stable output shape (SAT consumes this).
output "sql_warehouse_id" {
  description = "ID of the default serverless warehouse; \"\" when default compute is disabled"
  value       = var.enable_default_compute ? databricks_sql_endpoint.default-serverless-warehouse-small[0].id : ""
}

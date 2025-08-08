output "catalog" {
  value = databricks_catalog.this.name
}

output "sql_warehouse_id" {
  value = databricks_sql_endpoint.default-serverless-warehouse-small.id
}

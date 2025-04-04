data "databricks_node_type" "smallest" {
  provider  = databricks.workspace
  local_disk = true
}

data "databricks_spark_version" "latest-lts" {
  provider  = databricks.workspace
  long_term_support = true
}

data "databricks_current_user" "me" {
  provider = databricks.workspace
}

data "databricks_node_type" "smallest" {
  provider  = databricks.workspace
  local_disk = true
  min_cores             = 4
  gb_per_core           = 8
  photon_worker_capable = true
  photon_driver_capable = true
}

data "databricks_spark_version" "latest-lts" {
  provider  = databricks.workspace
  long_term_support = true
}

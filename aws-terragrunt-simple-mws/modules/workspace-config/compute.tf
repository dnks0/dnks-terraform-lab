resource "databricks_cluster" "default-classic-single-node" {
  provider                = databricks.workspace
  cluster_name            = "${var.business_unit}-sn-lts"
  spark_version           = data.databricks_spark_version.latest-lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 10
  spark_conf              = {
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }
  data_security_mode = "USER_ISOLATION"

  custom_tags = {
    "ResourceClass" = "SingleNode"
  }
}

resource "databricks_sql_endpoint" "default-serverless-warehouse-small" {
  provider                  = databricks.workspace
  name                      = "${var.business_unit}-serverless-warehouse"
  cluster_size              = "Small"
  max_num_clusters          = 1
  auto_stop_mins            = 10
  enable_serverless_compute = true
}

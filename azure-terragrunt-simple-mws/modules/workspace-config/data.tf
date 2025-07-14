data "http" "this" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

data "databricks_node_type" "smallest" {
  provider  = databricks.workspace
  local_disk = true
}

data "databricks_spark_version" "latest-lts" {
  provider  = databricks.workspace
  long_term_support = true
}

data "azurerm_private_dns_zone" "dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = var.azure_resource_group_name
}

data "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.azure_resource_group_name
}

data "azurerm_subnet" "privatelink" {
  name                 = "${var.prefix}-privatelink-snt"
  virtual_network_name = "${var.prefix}-vnet"
  resource_group_name  = var.azure_resource_group_name
}

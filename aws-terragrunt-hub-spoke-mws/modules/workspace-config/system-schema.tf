#resource "databricks_system_schema" "this" {
#  for_each  = toset(var.system_schemas)
#  provider  = databricks.workspace
#  schema    = each.value

#  lifecycle {
#    prevent_destroy = true
#  }
#}

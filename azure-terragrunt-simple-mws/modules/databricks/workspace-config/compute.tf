resource "databricks_cluster" "default-classic-single-node" {
  provider                = databricks.workspace
  count                   = var.enable_default_compute ? 1 : 0
  cluster_name            = "${var.business_unit}-sn-lts"
  spark_version           = data.databricks_spark_version.latest-lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 10
  spark_conf = {
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }
  data_security_mode = "USER_ISOLATION"

  custom_tags = {
    "ResourceClass" = "SingleNode"
  }
  no_wait = true
}

resource "databricks_sql_endpoint" "default-serverless-warehouse-small" {
  provider                  = databricks.workspace
  count                     = var.enable_default_compute ? 1 : 0
  name                      = "${var.business_unit}-serverless-warehouse"
  cluster_size              = "Small"
  max_num_clusters          = 1
  auto_stop_mins            = 10
  enable_serverless_compute = true
}

# Remove the auto-provisioned "Starter Warehouse" that Databricks creates for every new
# workspace. Terraform can't delete a resource it didn't create, so this is an imperative
# step: find the warehouse by name and delete it via the Databricks CLI during apply.
#
# Auth: DATABRICKS_HOST is set to the workspace URL; the deployer service principal is
# picked up from the ARM_* env vars already present during the run (same creds the stack
# authenticates Databricks with). A short retry loop handles the fact that Databricks
# creates the starter warehouse asynchronously after the workspace comes up.
#
# Gated by enable_default_compute: when we provision our own default compute we also
# remove the redundant auto-created starter warehouse (no separate flag).
resource "terraform_data" "starter_warehouse" {
  count = var.enable_default_compute ? 1 : 0

  # Re-run only if the target workspace changes.
  triggers_replace = [var.workspace_host]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      DATABRICKS_HOST = var.workspace_host
    }
    command = <<-EOT
      set -euo pipefail
      for attempt in 1 2 3 4 5 6; do
        id=$(databricks warehouses list --output json 2>/dev/null | python3 -c "
import json, sys
try:
    ws = json.load(sys.stdin) or []
except Exception:
    ws = []
print(next((w['id'] for w in ws if 'Starter Warehouse' in (w.get('name') or '')), ''))
")
        if [ -n "$id" ]; then
          echo "Deleting Starter Warehouse ($id)"
          databricks warehouses delete "$id"
          exit 0
        fi
        echo "Starter Warehouse not found yet (attempt $attempt/6); waiting 10s..."
        sleep 10
      done
      echo "No Starter Warehouse found after retries; nothing to delete."
    EOT
  }
}

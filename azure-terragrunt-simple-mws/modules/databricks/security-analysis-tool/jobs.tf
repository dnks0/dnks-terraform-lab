resource "databricks_job" "initializer-job" {
  provider  = databricks.workspace
  name = "security-analysis-tool-initializer-job"
  dynamic "job_cluster" {
    for_each = var.serverless ? [] : [1]
    content {
      job_cluster_key = "sat-job-cluster"
      new_cluster {
        data_security_mode = "SINGLE_USER"
        num_workers        = 5
        spark_version      = data.databricks_spark_version.latest-lts.id
        node_type_id       = data.databricks_node_type.smallest.id
        runtime_engine     = "PHOTON"
      }
    }
  }

  task {
    task_key        = "sat-initializer"
    job_cluster_key = var.serverless ? null : "sat-job-cluster"
    dynamic "library" {
      for_each = var.serverless ? [] : [1]
      content {
        pypi {
          package = "dbl-sat-sdk"
        }
      }
    }
    notebook_task {
      notebook_path = "${databricks_repo.this.workspace_path}/notebooks/security_analysis_initializer"
    }
  }

}

resource "databricks_job" "driver-job" {
  provider  = databricks.workspace
  name = "security-analysis-tool-driver-job"
  dynamic "job_cluster" {
    for_each = var.serverless ? [] : [1]
    content {
      job_cluster_key = "sat-job-cluster"
      new_cluster {
        data_security_mode = "SINGLE_USER"
        num_workers        = 5
        spark_version      = data.databricks_spark_version.latest-lts.id
        node_type_id       = data.databricks_node_type.smallest.id
        runtime_engine     = "PHOTON"
      }
    }
  }


  task {
    task_key        = "sat-driver"
    job_cluster_key = var.serverless ? null : "sat-job-cluster"
    dynamic "library" {
      for_each = var.serverless ? [] : [1]
      content {
        pypi {
          package = "dbl-sat-sdk"
        }
      }
    }
    notebook_task {
      notebook_path = "${databricks_repo.this.workspace_path}/notebooks/security_analysis_driver"
    }
  }

  schedule {
    #E.G. At 08:00:00am, on every Monday, Wednesday and Friday, every month; For more: http://www.quartz-scheduler.org/documentation/quartz-2.3.0/tutorials/crontrigger.html
    quartz_cron_expression = "0 0 8 ? * Mon,Wed,Fri"
    # The system default is UTC; For more: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
    timezone_id = "Europe/Berlin"
  }
}

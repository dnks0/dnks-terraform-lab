resource "databricks_job" "initializer-job" {
  provider = databricks.workspace
  name     = "security-analysis-tool-initializer-job"
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

  dynamic "environment" {
    for_each = var.serverless ? [1] : []
    content {
      environment_key = "default"
      spec {
        client = "5"
      }
    }
  }

  task {
    task_key        = "sat-initializer"
    job_cluster_key = var.serverless ? null : "sat-job-cluster"
    environment_key = var.serverless ? "default" : null
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
  provider = databricks.workspace
  name     = "security-analysis-tool-driver-job"
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


  dynamic "environment" {
    for_each = var.serverless ? [1] : []
    content {
      environment_key = "default"
      spec {
        client = "5"
      }
    }
  }

  task {
    task_key        = "sat-driver"
    job_cluster_key = var.serverless ? null : "sat-job-cluster"
    environment_key = var.serverless ? "default" : null
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

resource "databricks_job" "secrets-scanner-job" {
  provider = databricks.workspace
  name     = "security-analysis-tool-secrets-scanner-job"
  # Upper bound for the whole run: fail fast instead of hanging if a scan gets stuck.
  timeout_seconds = 28800 # 8 hours
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

  dynamic "environment" {
    for_each = var.serverless ? [1] : []
    content {
      environment_key = "default"
      spec {
        client = "5"
      }
    }
  }

  task {
    task_key        = "sat-secrets-scanner"
    job_cluster_key = var.serverless ? null : "sat-job-cluster"
    environment_key = var.serverless ? "default" : null
    dynamic "library" {
      for_each = var.serverless ? [] : [1]
      content {
        pypi {
          package = "dbl-sat-sdk"
        }
      }
    }
    notebook_task {
      notebook_path = "${databricks_repo.this.workspace_path}/notebooks/security_analysis_secrets_scanner"
    }
  }

  schedule {
    # Offset 2 hours after the driver job to avoid Delta write conflicts on the shared control
    # tables (security_checks, account_info, run_number_table); mirrors the upstream SAT default.
    quartz_cron_expression = "0 0 10 ? * Mon,Wed,Fri"
    timezone_id            = "Europe/Berlin"
  }
}

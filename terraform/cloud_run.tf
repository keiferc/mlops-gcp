# Cloud Run Service for MLflow Server
resource "google_cloud_run_v2_service" "mlflow" {
  name     = var.cloud_run_service_name
  location = var.region

  template {
    service_account = google_service_account.mlflow_cloud_run.email

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repo_name}/mlflow:latest"

      env {
        name  = "MLFLOW_BACKEND_STORE_URI"
        value = "postgresql://${var.cloud_sql_db_user}:${random_string.db_password.result}@localhost:5432/${var.cloud_sql_database_name}"
      }

      env {
        name  = "MLFLOW_DEFAULT_ARTIFACT_ROOT"
        value = "gs://${google_storage_bucket.mlflow_artifacts.name}/artifacts"
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      ports {
        container_port = 5000
      }
    }
  }

  traffic {
    type    = "ALL"
    percent = 100
  }
}

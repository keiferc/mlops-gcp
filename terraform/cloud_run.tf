# Cloud Run Service for MLflow Server
resource "google_cloud_run_v2_service" "mlflow" {
  name     = var.cloud_run_service_name
  location = var.region

  deletion_protection = false

  template {
    service_account = google_service_account.mlflow_cloud_run.email

    # Set resource limits for personal use (small machine)
    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    containers {
      # Replace with your Artifact Registry image URL
      # Format: {region}-docker.pkg.dev/{project_id}/{repo_name}/mlflow:latest
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repo_name}/mlflow:latest"

      # Environment variables for MLflow
      env {
        name  = "MLFLOW_BACKEND_STORE_URI"
        value = "postgresql://${var.cloud_sql_db_user}:${random_string.db_password.result}@${google_sql_database_instance.mlflow.private_ip_address}:5432/${var.cloud_sql_database_name}"
      }

      env {
        name  = "MLFLOW_DEFAULT_ARTIFACT_ROOT"
        value = "gs://${google_storage_bucket.mlflow_artifacts.name}/artifacts"
      }

      # Startup probe to wait for MLflow to be ready
      startup_probe {
        http_get {
          path = "/"
        }
        failure_threshold = 5
        timeout_seconds   = 5
      }

      # Liveness probe to check MLflow health
      liveness_probe {
        http_get {
          path = "/"
        }
        failure_threshold = 3
        timeout_seconds   = 5
      }

      # Resource limits
      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      # Port for MLflow UI
      ports {
        container_port = 5000
      }
    }

    # Use a VPC connector to access Cloud SQL (Cloud SQL can be reached via private IP)
    vpc_access {
      connector = google_vpc_access_connector.mlflow.id
      egress    = "PRIVATE_RANGES_ONLY"
    }
  }

  # Traffic routing
  traffic {
    type    = "ALL"
    percent = 100
  }

  labels = local.labels
}

# VPC Access Connector to allow Cloud Run to access Cloud SQL
resource "google_vpc_access_connector" "mlflow" {
  name          = "mlflow-connector"
  region        = var.region
  ip_cidr_range = "10.8.0.0/28"  # Small range for personal use
}

# Enable Private IP for Cloud SQL if not already enabled
resource "google_sql_database_instance_network" "mlflow_network" {
  instance = google_sql_database_instance.mlflow.name
}

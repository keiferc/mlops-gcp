# ---------------------------------------------------------------------------
# Cloud Run service running the MLflow tracking server.
#
# The shell wrapper (command + args) is required so that the environment
# variable $MLFLOW_BACKEND_STORE_URI — injected from Secret Manager — is
# expanded by the shell at container startup time.
#
# Note: Terraform interpolates ${var.*} at plan/apply time.
#       The shell expands $MLFLOW_BACKEND_STORE_URI at container runtime.
# ---------------------------------------------------------------------------
resource "google_cloud_run_v2_service" "mlflow" {
  depends_on = [
    google_project_service.apis,
    google_sql_database.mlflow,
    google_sql_user.mlflow,
    google_secret_manager_secret_version.mlflow_db_url,
  ]

  project  = var.project_id
  name     = var.cloud_run_service_name
  location = var.region

  # INGRESS_TRAFFIC_ALL allows traffic from the internet and from Vertex AI.
  # Security is enforced via IAM (no allUsers invoker — see iam.tf).
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.cloud_run.email

    # min=0 scales to zero when idle (zero cost when not in use).
    # max=1 keeps resource usage minimal for personal projects.
    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    # Cloud Run mounts the Cloud SQL Unix socket at /cloudsql/.
    # This allows MLflow to connect to PostgreSQL without a public DB endpoint.
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.mlflow.connection_name]
      }
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repo_name}/mlflow:latest"

      # /bin/sh -c expands $MLFLOW_BACKEND_STORE_URI from the environment.
      command = ["/bin/sh", "-c"]
      args = [
        "mlflow server --host 0.0.0.0 --port $PORT --backend-store-uri $MLFLOW_BACKEND_STORE_URI --artifacts-destination gs://${var.mlflow_artifact_bucket_name}/artifacts --serve-artifacts"
      ]

      # Pull the full Postgres URI from Secret Manager at container startup.
      env {
        name = "MLFLOW_BACKEND_STORE_URI"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.mlflow_db_url.secret_id
            version = "latest"
          }
        }
      }

      ports {
        container_port = 5000
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }
  }
}

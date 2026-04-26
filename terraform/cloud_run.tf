# Cloud Run service account
resource "google_service_account" "mlflow_cloudrun" {
  account_id   = "mlflow-cloudrun"
  display_name = "MLflow Cloud Run Service Account"

  depends_on = [google_project_service.required_apis]
}

# Grant Cloud Run service account access to Secret Manager
resource "google_secret_manager_secret_iam_member" "mlflow_secret_access" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.mlflow_cloudrun.email}"

  depends_on = [google_service_account.mlflow_cloudrun]
}

# Grant Cloud Run service account access to Cloud Storage artifacts
resource "google_storage_bucket_iam_member" "mlflow_artifact_access" {
  bucket = google_storage_bucket.artifacts.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.mlflow_cloudrun.email}"

  depends_on = [google_service_account.mlflow_cloudrun]
}

# VPC Access Connector for Cloud SQL private IP access
resource "google_vpc_access_connector" "mlflow" {
  name           = "mlflow-vpc-connector"
  region         = var.region
  ip_cidr_range  = "10.8.0.0/28"
  network        = google_compute_network.mlflow_network.name
  min_throughput = 200
  max_throughput = 300

  depends_on = [google_project_service.required_apis]
}

# Cloud Run service (private)
resource "google_cloud_run_v2_service" "mlflow" {
  name     = var.cloud_run_service_name
  location = var.region

  template {
    service_account = google_service_account.mlflow_cloudrun.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repo}/mlflow:latest"

      ports {
        container_port = 5000
      }

      env {
        name  = "MLFLOW_BACKEND_STORE_URI"
        value = "postgresql://${var.db_user}:${var.db_password}@${google_sql_database_instance.mlflow.private_ip_address}:5432/${var.db_name}"
      }

      env {
        name  = "MLFLOW_DEFAULT_ARTIFACT_ROOT"
        value = "gs://${google_storage_bucket.artifacts.name}"
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }

    scaling {
      max_instance_count = 2
    }

    vpc_access {
      connector = google_vpc_access_connector.mlflow.id
      egress    = "PRIVATE_RANGES_ONLY"
    }

  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [
    google_project_service.required_apis,
    google_secret_manager_secret_iam_member.mlflow_secret_access,
    google_storage_bucket_iam_member.mlflow_artifact_access,
  ]
}

# Remove public access to Cloud Run service
resource "google_cloud_run_v2_service_iam_member" "noauth" {
  location = google_cloud_run_v2_service.mlflow.location
  name     = google_cloud_run_v2_service.mlflow.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.mlflow_cloudrun.email}"

  depends_on = [google_cloud_run_v2_service.mlflow]
}

output "mlflow_service_url" {
  description = "Internal Cloud Run service URL (accessible via GCP Console)"
  value       = google_cloud_run_v2_service.mlflow.uri
  depends_on  = [google_cloud_run_v2_service.mlflow]
}

output "mlflow_cloud_run_service_account" {
  description = "Cloud Run service account email"
  value       = google_service_account.mlflow_cloudrun.email
}

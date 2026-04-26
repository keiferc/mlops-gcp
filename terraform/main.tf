terraform {
  required_version = ">= 1.14"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  # Uncomment to use GCS backend for state file (recommended for shared environments)
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "mlflow"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "cloudrun.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = true
}

output "mlflow_service_url" {
  description = "Internal Cloud Run service URL (accessible via GCP Console)"
  value       = google_cloud_run_service.mlflow.statuses[0].url
  depends_on  = [google_cloud_run_service.mlflow]
}

output "database_connection_name" {
  description = "Cloud SQL connection name for Vertex AI"
  value       = google_sql_database_instance.mlflow.connection_name
}

output "artifact_bucket_name" {
  description = "Cloud Storage bucket for artifacts"
  value       = google_storage_bucket.artifacts.name
}

output "secret_manager_secret_id" {
  description = "Secret Manager secret ID containing database credentials"
  value       = google_secret_manager_secret.db_password.id
}

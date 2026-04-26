output "cloud_run_service_url" {
  description = "MLflow UI URL (Cloud Run service)"
  value       = google_cloud_run_v2_service.mlflow.uri
}

output "artifact_registry_image_url" {
  description = "Artifact Registry image URL (push your MLflow Docker image here)"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repo_name}/mlflow"
}

output "cloud_sql_connection_name" {
  description = "Cloud SQL connection name for Vertex AI (if using Cloud SQL Proxy)"
  value       = google_sql_database_instance.mlflow.connection_name
}

output "cloud_sql_private_ip" {
  description = "Cloud SQL private IP address (for direct connection from Vertex AI)"
  value       = google_sql_database_instance.mlflow.private_ip_address
}

output "mlflow_artifacts_bucket" {
  description = "Cloud Storage bucket for MLflow artifacts"
  value       = google_storage_bucket.mlflow_artifacts.name
}

output "mlflow_backend_store_uri" {
  description = "MLflow backend store URI (connection string for Vertex AI)"
  value       = "postgresql://${var.cloud_sql_db_user}:${random_string.db_password.result}@${google_sql_database_instance.mlflow.private_ip_address}:5432/${var.cloud_sql_database_name}"
  sensitive   = true
}

output "mlflow_artifact_root_uri" {
  description = "MLflow artifact root URI for Vertex AI"
  value       = "gs://${google_storage_bucket.mlflow_artifacts.name}/artifacts"
}

output "default_compute_service_account_email" {
  description = "Default Compute Engine service account email (used by Vertex AI)"
  value       = data.google_compute_default_service_account.default.email
}

output "mlflow_tracking_uri" {
  description = "Cloud Run URL — use this as MLFLOW_TRACKING_URI in your training scripts"
  value       = google_cloud_run_v2_service.mlflow.uri
}

output "artifact_bucket_name" {
  description = "GCS bucket storing MLflow artifacts"
  value       = google_storage_bucket.mlflow_artifacts.name
}

output "docker_image_uri" {
  description = "Full Artifact Registry URI for the MLflow image"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repo_name}/mlflow:latest"
}

output "cloud_sql_connection_name" {
  description = "Cloud SQL connection name (useful for debugging)"
  value       = google_sql_database_instance.mlflow.connection_name
}

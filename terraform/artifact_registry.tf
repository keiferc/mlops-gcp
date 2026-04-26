resource "google_artifact_registry_repository" "mlflow" {
  location      = var.region
  repository_id = var.artifact_registry_repo
  description   = "Docker repository for MLflow"
  format        = "DOCKER"
  mode          = "STANDARD_REPOSITORY"

  depends_on = [google_project_service.required_apis]
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.mlflow.repository_id}"
}

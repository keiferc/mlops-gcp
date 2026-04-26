# ---------------------------------------------------------------------------
# Docker repository for the MLflow server image.
# The image must be pushed here BEFORE running the full terraform apply.
# (See deployment steps in README)
# ---------------------------------------------------------------------------
resource "google_artifact_registry_repository" "mlflow" {
  depends_on = [google_project_service.apis]

  project       = var.project_id
  location      = var.region
  repository_id = var.artifact_registry_repo_name
  description   = "Docker repository for the MLflow server image"
  format        = "DOCKER"
}

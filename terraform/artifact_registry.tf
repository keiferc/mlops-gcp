# Artifact Registry Docker Repository
resource "google_artifact_registry_repository" "mlflow" {
  location      = var.region
  repository_id = var.artifact_registry_repo_name
  description   = "MLflow server Docker images"
  format        = "DOCKER"

  labels = local.labels
}

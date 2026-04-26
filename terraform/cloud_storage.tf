# Cloud Storage Bucket for MLflow Artifacts
resource "google_storage_bucket" "mlflow_artifacts" {
  name                        = var.mlflow_artifact_bucket_name
  location                    = var.region
  uniform_bucket_level_access = true  # Enforce uniform IAM

  # Public Access Prevention
  public_access_prevention = "enforced"

  labels = local.labels
}

# Deny public access explicitly
resource "google_storage_bucket_iam_binding" "mlflow_artifacts_deny_public" {
  bucket = google_storage_bucket.mlflow_artifacts.name
  role   = "roles/storage.objectViewer"
  members = []  # No public members
}

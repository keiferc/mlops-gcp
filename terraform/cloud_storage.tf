resource "google_storage_bucket" "mlflow_artifacts" {
  depends_on = [google_project_service.apis]

  name                        = var.mlflow_artifact_bucket_name
  location                    = var.region
  force_destroy               = true
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
}

# Cloud Run SA writes artifacts on behalf of the MLflow server process.
resource "google_storage_bucket_iam_member" "cloud_run_gcs" {
  bucket = google_storage_bucket.mlflow_artifacts.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Vertex AI (default Compute Engine SA) writes artifacts directly to GCS.
resource "google_storage_bucket_iam_member" "vertex_ai_gcs" {
  bucket = google_storage_bucket.mlflow_artifacts.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

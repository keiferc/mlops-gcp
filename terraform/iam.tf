# Service Account for Cloud Run MLflow server
resource "google_service_account" "mlflow_cloud_run" {
  account_id   = "mlflow-cloud-run"
  display_name = "MLflow Cloud Run Service Account"
}

# Get Default Compute Engine Service Account (used by Vertex AI)
data "google_compute_default_service_account" "default" {}

# Grant Default Service Account access to Cloud SQL (for Vertex AI)
resource "google_project_iam_member" "default_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

# Grant Default Service Account access to Cloud Storage artifacts (for Vertex AI)
resource "google_storage_bucket_iam_member" "default_storage_user" {
  bucket = google_storage_bucket.mlflow_artifacts.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

# Grant Default Service Account access to Cloud SQL password secret (for Vertex AI)
resource "google_secret_manager_secret_iam_member" "default_db_password" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

# Grant Default Service Account access to connection string secret
resource "google_secret_manager_secret_iam_member" "default_db_conn_string" {
  secret_id = google_secret_manager_secret.db_connection_string.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

# Grant Cloud Run Service Account permission to pull images from Artifact Registry
resource "google_artifact_registry_repository_iam_member" "mlflow_cloud_run_pull" {
  location   = google_artifact_registry_repository.mlflow.location
  repository = google_artifact_registry_repository.mlflow.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.mlflow_cloud_run.email}"
}

# Grant your user (via email) access to invoke Cloud Run service
resource "google_cloud_run_v2_service_iam_member" "mlflow_user_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.mlflow.name
  role     = "roles/run.invoker"
  member   = "user:${var.user_email}"
}

# Grant Cloud Run Service Account permission to use Cloud SQL Auth proxy
resource "google_project_iam_member" "mlflow_cloud_run_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.mlflow_cloud_run.email}"
}

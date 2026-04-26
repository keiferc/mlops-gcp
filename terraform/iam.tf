# ---------------------------------------------------------------------------
# Grants artifact registry writing permissions to user
# ---------------------------------------------------------------------------
resource "google_project_iam_member" "artifact_registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "user:${var.user_email}"
}

# ---------------------------------------------------------------------------
# Dedicated service account for the Cloud Run MLflow server process.
# ---------------------------------------------------------------------------
resource "google_service_account" "cloud_run" {
  project      = var.project_id
  account_id   = "mlflow-cloud-run-sa"
  display_name = "MLflow Cloud Run Service Account"
}

# Cloud Run needs Cloud SQL Client to open the Unix socket to PostgreSQL.
resource "google_project_iam_member" "cloud_run_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# ---------------------------------------------------------------------------
# The default Compute Engine SA is automatically used by Vertex AI jobs.
# depends_on ensures the Compute Engine API is enabled before this is read.
# ---------------------------------------------------------------------------
data "google_compute_default_service_account" "default" {
  project    = var.project_id
  depends_on = [google_project_service.apis]
}

# ---------------------------------------------------------------------------
# Cloud Run invoker grants — NO public (allUsers) access is granted.
# Cloud Run automatically rejects requests without a valid Google identity
# token, so only these two principals can reach the MLflow server.
#
# To open the MLflow UI in your browser, run:
#   gcloud run services proxy SERVICE_NAME --region=REGION --port=5000
# then open http://localhost:5000
# ---------------------------------------------------------------------------
resource "google_cloud_run_v2_service_iam_member" "owner_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.mlflow.name
  role     = "roles/run.invoker"
  member   = "user:${var.user_email}"
}

resource "google_cloud_run_v2_service_iam_member" "vertex_ai_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.mlflow.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

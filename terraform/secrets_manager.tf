resource "google_secret_manager_secret" "db_password" {
  secret_id = "mlflow-db-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}

# Grant Secret Manager access to Vertex AI service account
# Note: Update the Vertex AI service account email if different
resource "google_secret_manager_secret_iam_member" "vertex_ai_access" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_client_config.default.project}@aiplatform.iam.gserviceaccount.com"

  depends_on = [google_secret_manager_secret.db_password]
}

data "google_client_config" "default" {}

output "secret_manager_secret_version" {
  description = "Secret Manager secret version"
  value       = google_secret_manager_secret_version.db_password.name
}

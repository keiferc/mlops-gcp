resource "random_password" "db_password" {
  length  = 32
  special = false # prevents URL encoding issues
  min_numeric = 2
  min_upper = 2
}

# Store the full PostgreSQL connection URI as one secret so Cloud Run can
# inject it directly as an env var — no string manipulation at runtime.
resource "google_secret_manager_secret" "mlflow_db_url" {
  depends_on = [google_project_service.apis]

  project   = var.project_id
  secret_id = "mlflow-db-url"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "mlflow_db_url" {
  secret = google_secret_manager_secret.mlflow_db_url.id

  # Cloud Run mounts the Cloud SQL socket at /cloudsql/.
  # SQLAlchemy psycopg2 uses the `host` query param for the socket directory.
  secret_data = "postgresql+psycopg2://${var.cloud_sql_db_user}:${random_password.db_password.result}@/${var.cloud_sql_database_name}?host=/cloudsql/${var.project_id}:${var.region}:${var.cloud_sql_instance_name}"
}

# Allow the Cloud Run SA to read this secret at container startup.
resource "google_secret_manager_secret_iam_member" "cloud_run_secret" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.mlflow_db_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run.email}"
}

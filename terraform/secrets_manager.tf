# Store Cloud SQL Database Password in Secrets Manager
resource "google_secret_manager_secret" "db_password" {
  secret_id = "mlflow-db-password"
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]

  replication {
    auto {}
  }
}

# Secret Version (actual password value)
resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_string.db_password.result
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

# Store Cloud SQL connection string secret
resource "google_secret_manager_secret" "db_connection_string" {
  secret_id = "mlflow-db-connection-string"
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_connection_string" {
  secret = google_secret_manager_secret.db_connection_string.id
  secret_data = format(
    "postgresql://%s:%s@%s/%s",
    var.cloud_sql_db_user,
    random_string.db_password.result,
    google_sql_database_instance.mlflow.private_ip_address,
    var.cloud_sql_database_name
  )
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

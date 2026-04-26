# ---------------------------------------------------------------------------
# Cloud SQL PostgreSQL instance — smallest tier for personal projects.
#
# deletion_protection = false  -> lets "terraform destroy" delete the instance
# backup_configuration.enabled = false  → saves cost; enable for production
# ---------------------------------------------------------------------------
resource "google_sql_database_instance" "mlflow" {
  depends_on = [google_project_service.apis]

  project          = var.project_id
  name             = var.cloud_sql_instance_name
  database_version = "POSTGRES_15"
  region           = var.region

  deletion_protection = false

  settings {
    tier = "db-f1-micro"

    backup_configuration {
      enabled = false
    }

    ip_configuration {
      ipv4_enabled = true
    }
  }
}

resource "google_sql_database" "mlflow" {
  project  = var.project_id
  name     = var.cloud_sql_database_name
  instance = google_sql_database_instance.mlflow.name
}

resource "google_sql_user" "mlflow" {
  project  = var.project_id
  name     = var.cloud_sql_db_user
  instance = google_sql_database_instance.mlflow.name
  password = random_password.db_password.result
}

resource "google_sql_database_instance" "mlflow" {
  depends_on = [google_project_service.apis]

  project          = var.project_id
  name             = var.cloud_sql_instance_name
  database_version = "POSTGRES_15"
  region           = var.region

  deletion_protection = false

  settings {
    tier = "db-f1-micro" # smallest tier for cost savings

    backup_configuration {
      enabled = false # saves cost; enable for production
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
  deletion_policy = "ABANDON" # resource deleted when instance is deleted
}

resource "google_sql_user" "mlflow" {
  project  = var.project_id
  name     = var.cloud_sql_db_user
  instance = google_sql_database_instance.mlflow.name
  password = random_password.db_password.result
  deletion_policy = "ABANDON" # resource deleted when instance is deleted
}

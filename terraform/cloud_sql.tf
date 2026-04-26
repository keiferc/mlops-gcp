# Cloud SQL PostgreSQL Instance
resource "google_sql_database_instance" "mlflow" {
  name               = var.cloud_sql_instance_name
  database_version   = "POSTGRES_15"
  region             = var.region
  deletion_protection = false  # Set to true in production for safety

  settings {
    tier              = "db-f1-micro"  # Free tier for personal projects
    availability_type = "REGIONAL"     # Not required for personal use but good practice
    backup_configuration {
      enabled = true
    }

    ip_configuration {
      ipv4_enabled                                  = false  # Disable public IP for security
      private_network                               = "projects/${var.project_id}/global/networks/default"
      enable_private_path_for_google_cloud_services =  true
    }
  }
}

# MLflow Database
resource "google_sql_database" "mlflow" {
  name     = var.cloud_sql_database_name
  instance = google_sql_database_instance.mlflow.name
}

# MLflow Database User
resource "google_sql_user" "mlflow" {
  name     = var.cloud_sql_db_user
  instance = google_sql_database_instance.mlflow.name
  password = random_string.db_password.result
}

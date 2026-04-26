resource "google_sql_database_instance" "mlflow" {
  name             = var.db_instance_name
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier              = "db-f1-micro" # Smallest tier for personal projects
    availability_type = "ZONAL"       # Single zone (no redundancy)

    ip_configuration {
      private_network   = google_compute_network.mlflow_network.id
      ipv4_enabled      = false # Only private IP
      enable_private_path_for_google_cloud_services = true
    }
  }

  deletion_protection = false # Allow deletion via terraform destroy

  depends_on = [
    google_project_service.required_apis,
    google_service_networking_connection.private_vpc_connection,
  ]
}

resource "google_sql_database" "mlflow" {
  name     = var.db_name
  instance = google_sql_database_instance.mlflow.name

  depends_on = [google_sql_database_instance.mlflow]
}

resource "google_sql_user" "mlflow" {
  name     = var.db_user
  instance = google_sql_database_instance.mlflow.name
  password = var.db_password

  depends_on = [google_sql_database_instance.mlflow]
}

# VPC Network for Cloud SQL private IP
resource "google_compute_network" "mlflow_network" {
  name                    = "mlflow-network"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.required_apis]
}

resource "google_compute_subnetwork" "mlflow_subnet" {
  name          = "mlflow-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.mlflow_network.id
}

# Private VPC connection for Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.mlflow_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.required_apis]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "mlflow-db-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.mlflow_network.id
}

output "database_instance_name" {
  description = "Cloud SQL instance name"
  value       = google_sql_database_instance.mlflow.name
}

output "database_private_ip" {
  description = "Cloud SQL private IP address"
  value       = google_sql_database_instance.mlflow.private_ip_address
}

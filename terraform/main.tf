terraform {
  required_version = ">= 1.3, <= 1.5.7"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Generate random password for Cloud SQL
resource "random_string" "db_password" {
  length  = 32
  special = true
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "iam.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com"
  ])

  service  = each.value
  project  = var.project_id

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_on_destroy = true
}

# Reserve global address for Private Service Connection
resource "google_compute_global_address" "private_sql_ip" {
  name          = "google-managed-services-default"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "default"

  depends_on = [google_project_service.required_apis]
}

# Create the Private Service Connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = "default"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_sql_ip.name]

  depends_on = [google_project_service.required_apis]
}

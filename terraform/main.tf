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

# Generate a random suffix for uniqueness
resource "random_string" "db_password" {
  length  = 32
  special = true
}

# Local values for common naming and configurations
locals {
  environment = "mlflow"
  labels = {
    environment = local.environment
    managed_by  = "terraform"
  }
}

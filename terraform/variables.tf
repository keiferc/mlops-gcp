variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "db_instance_name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "mlflow-db"
}

variable "db_name" {
  description = "MLflow database name"
  type        = string
  default     = "mlflow"
}

variable "db_user" {
  description = "MLflow database user"
  type        = string
  default     = "mlflow"
}

variable "db_password" {
  description = "MLflow database password (will be stored in Secret Manager)"
  type        = string
  sensitive   = true
}

variable "artifact_bucket_name" {
  description = "Cloud Storage bucket for MLflow artifacts"
  type        = string
}

variable "artifact_registry_repo" {
  description = "Artifact Registry repository name"
  type        = string
  default     = "mlflow-docker"
}

variable "cloud_run_service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "mlflow-server"
}

variable "mlflow_tracking_uri" {
  description = "MLflow tracking URI (internal Cloud SQL connection)"
  type        = string
  default     = "postgresql"
}

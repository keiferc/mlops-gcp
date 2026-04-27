variable "project_id" {
  description = "Your GCP project ID (e.g. my-project-123456)"
  type        = string
}

variable "region" {
  description = "GCP region for all resources"
  type        = string
  default     = "us-central1"
}

variable "user_email" {
  description = "Your Google account email — this account gets access to the MLflow UI"
  type        = string
}

variable "mlflow_artifact_bucket_name" {
  description = "GCS bucket name for MLflow artifacts. Must be globally unique across all of GCP."
  type        = string
}

variable "artifact_registry_repo_name" {
  description = "Artifact Registry Docker repository name"
  type        = string
  default     = "mlflow-repo"
}

variable "cloud_run_service_name" {
  description = "Cloud Run service name for the MLflow server"
  type        = string
  default     = "mlflow-server"
}

variable "cloud_sql_instance_name" {
  description = "Cloud SQL instance name. After deletion, this name cannot be reused for 7 days."
  type        = string
  default     = "mlflow-postgres"
}

variable "cloud_sql_database_name" {
  description = "PostgreSQL database name for MLflow"
  type        = string
  default     = "mlflow-db"
}

variable "cloud_sql_db_user" {
  description = "PostgreSQL username for MLflow"
  type        = string
  default     = "mlflow-user"
}

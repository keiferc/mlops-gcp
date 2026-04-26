variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "user_email" {
  description = "Your email address. Used to grant Cloud Run access."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.user_email))
    error_message = "Must be a valid email address."
  }
}

variable "mlflow_artifact_bucket_name" {
  description = "Unique name for the Cloud Storage bucket (must be globally unique). Suggest: mlflow-artifacts-${project_id}-${random_suffix}"
  type        = string
}

variable "artifact_registry_repo_name" {
  description = "Artifact Registry repository name"
  type        = string
  default     = "mlflow-repo"
}

variable "cloud_run_service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "mlflow-server"
}

variable "cloud_sql_instance_name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "mlflow-postgres"
}

variable "cloud_sql_database_name" {
  description = "Database name in Cloud SQL"
  type        = string
  default     = "mlflow"
}

variable "cloud_sql_db_user" {
  description = "Database user name"
  type        = string
  default     = "mlflow"
}

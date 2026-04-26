resource "google_storage_bucket" "artifacts" {
  name          = var.artifact_bucket_name
  location      = var.region
  force_destroy = true # Allow deletion even if bucket contains objects

  versioning {
    enabled = false # Disable versioning for cost savings in personal projects
  }

  uniform_bucket_level_access = true
  public_access_prevention = "enforced"

  depends_on = [google_project_service.required_apis]
}

output "artifact_bucket_url" {
  description = "Cloud Storage bucket URL"
  value       = "gs://${google_storage_bucket.artifacts.name}"
}

resource "google_artifact_registry_repository" "my_repo" {
  location      = var.location
  repository_id = var.repo_name
  description   = "Docker repository for Jenkins CI/CD"
  format        = "DOCKER"
}
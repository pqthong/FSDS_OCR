output "repository_url" {
  description = "The full URL of the Artifact Registry repository."
  value       = google_artifact_registry_repository.my_repo.name
}
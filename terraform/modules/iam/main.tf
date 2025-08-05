# Create a dedicated service account for Jenkins to use
resource "google_service_account" "jenkins_sa" {
  account_id   = "jenkins-gke-deployer"
  display_name = "Service Account for Jenkins to deploy to GKE"
}

# Grant the service account the Kubernetes Engine Developer role
resource "google_project_iam_member" "gke_developer_role" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.jenkins_sa.email}"
}

# Grant the service account the Storage Admin role
resource "google_project_iam_member" "storage_admin_role" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.jenkins_sa.email}"
}


resource "google_project_iam_member" "artifact_registry_writer_role" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.jenkins_sa.email}"
}
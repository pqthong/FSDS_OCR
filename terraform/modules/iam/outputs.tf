output "service_account_email" {
  description = "The email of the created service account."
  value       = google_service_account.jenkins_sa.email
}
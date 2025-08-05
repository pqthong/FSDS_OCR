output "jenkins_instance_ip" {
  description = "The public IP address of the Jenkins VM."
  value       = module.jenkins_instance.jenkins_instance_ip
}

output "gke_cluster_endpoint" {
  description = "The endpoint of the GKE cluster."
  value       = module.gke_cluster.endpoint
}

output "jenkins_initial_admin_password_command" {
  description = "SSH command to retrieve the initial Jenkins admin password."
  # Corrected both the VM name and project ID variable references
  value       = "gcloud compute ssh --zone=${var.gcp_zone} ${module.jenkins_instance.vm_name} --project=${var.project_id} --command='sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
}

output "artifact_registry_url" {
  description = "The URL of the Artifact Registry repository."
  value       = module.artifact_registry.repository_url
}
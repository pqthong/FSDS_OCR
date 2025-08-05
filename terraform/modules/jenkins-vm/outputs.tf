output "jenkins_instance_ip" {
  description = "The public IP address of the Jenkins VM."
  value       = google_compute_instance.jenkins_vm.network_interface[0].access_config[0].nat_ip
}

output "jenkins_initial_admin_password_command" {
  description = "SSH command to retrieve the initial Jenkins admin password."
  value       = "gcloud compute ssh --zone=${google_compute_instance.jenkins_vm.zone} ${google_compute_instance.jenkins_vm.name} --project=${var.project_id} --command='sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
}

# Add this new output to expose the VM name
output "vm_name" {
  description = "The name of the Jenkins VM instance."
  value       = google_compute_instance.jenkins_vm.name
}
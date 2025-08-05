variable "project_id" {
  description = "The ID of the Google Cloud Project."
  type        = string
  default     = "alert-basis-466711-e1"
}

variable "gcp_region" {
  description = "The GCP region to deploy resources into."
  type        = string
  default     = "asia-southeast1"
}

variable "gcp_zone" {
  description = "The GCP zone to deploy resources into."
  type        = string
  default     = "asia-southeast1-a"
}

# GKE Cluster Variables
variable "gke_cluster_name" {
  description = "The name for the GKE cluster."
  type        = string
  default     = "jenkins-managed-cluster"
}

variable "gke_node_count" {
  description = "The number of nodes in the GKE cluster's main node pool."
  type        = number
  default     = 1
}

variable "gke_node_machine_type" {
  description = "The machine type for the GKE nodes."
  type        = string
  default     = "e2-medium"
}

# Jenkins VM Variables
variable "jenkins_vm_name" {
  description = "The name for the Jenkins virtual machine."
  type        = string
  default     = "jenkins-vm-e2-medium"
}

# Artifact Registry Variables
variable "artifact_registry_repo_name" {
  description = "The name for the Artifact Registry Docker repository."
  type        = string
  default     = "jenkins-artifacts"
}
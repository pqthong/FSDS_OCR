terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

module "jenkins_iam" {
  source = "./modules/iam"
  project_id = var.project_id
}

module "gke_cluster" {
  source = "./modules/gke-cluster"

  cluster_name      = var.gke_cluster_name
  location          = var.gcp_zone
  node_count        = var.gke_node_count
  node_machine_type = var.gke_node_machine_type
}

module "jenkins_instance" {
  source = "./modules/jenkins-vm"

  vm_name               = var.jenkins_vm_name
  zone                  = var.gcp_zone
  service_account_email = module.jenkins_iam.service_account_email
  project_id            = var.project_id
}

module "artifact_registry" {
  source    = "./modules/artifact-registry"
  location  = var.gcp_region
  repo_name = var.artifact_registry_repo_name
}

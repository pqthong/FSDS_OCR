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

  cluster_name      = "jenkins-managed-cluster"
  location          = var.gcp_zone
  node_count        = 1
  node_machine_type = "e2-medium"
}

module "jenkins_instance" {
  source = "./modules/jenkins-vm"

  vm_name               = "jenkins-vm-e2-medium"
  zone                  = var.gcp_zone
  service_account_email = module.jenkins_iam.service_account_email
  project_id = var.project_id
}

module "artifact_registry" {
  source    = "./modules/artifact-registry"
  location  = var.gcp_region
  repo_name = "jenkins-artifacts"
}
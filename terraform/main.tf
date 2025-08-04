# main.tf

# Configure the Google Cloud provider
# Replace 'alert-basis-466711-e1' and 'asia-southeast1' with your own values
# This uses the default project and region from your gcloud configuration.
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.45.0"
    }
  }
}

provider "google" {
  project = "alert-basis-466711-e1"
  region  = "asia-southeast1"
}

# --- GKE Cluster Configuration ---

resource "google_container_cluster" "gke_cluster" {
  # The name of the GKE cluster
  name = "ocr-cluster"
  # The location for the cluster, referencing the provider's region
  location = "asia-southeast1"

  # We use the most basic machine type and node count for a simple cluster.
  node_config {
    machine_type = "e2-micro"
    disk_size_gb = 12
  }

  # Set the number of nodes in the cluster to the bare minimum.
  initial_node_count = 1
}


# --- Output the cluster details after creation ---

output "cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "cluster_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}

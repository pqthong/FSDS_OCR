# This resource creates the GKE cluster itself
resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  location                 = var.location
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = "default"
  subnetwork               = "default"
}

# This resource creates the custom node pool for the cluster
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.location
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  # This explicitly sets the Kubernetes version for the node pool.
  # It is set to the same version as the GKE cluster. This often
  # resolves API errors that require a version to be specified.
  version = google_container_cluster.primary.master_version

  node_config {
    # This is required to satisfy the GKE API.
    # It defines the scopes the nodes need to interact with GCP services.
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    # Machine type for the nodes
    machine_type = var.node_machine_type
    # The image type for the nodes. COS_CONTAINERD is a common choice.
    image_type   = "COS_CONTAINERD"
    # Specify a minimal disk size to be more cost-effective.
    disk_size_gb = 20
  }
}

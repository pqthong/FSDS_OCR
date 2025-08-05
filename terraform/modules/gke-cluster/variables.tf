variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
}

variable "location" {
  description = "The GCP region or zone for the cluster."
  type        = string
}

variable "node_count" {
  description = "The number of nodes in the GKE node pool."
  type        = number
  default     = 1
}

variable "node_machine_type" {
  description = "The machine type for the GKE nodes."
  type        = string
  default     = "e2-medium"
}
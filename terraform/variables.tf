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
  description = "The GCP zone to deploy the VM and GKE cluster into."
  type        = string
  default     = "asia-southeast1-a"
}
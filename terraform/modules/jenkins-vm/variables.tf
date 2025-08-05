variable "vm_name" {
  description = "The name of the Jenkins VM instance."
  type        = string
}

variable "project_id" {
  description = "The ID of the Google Cloud Project."
  type        = string
}

variable "zone" {
  description = "The GCP zone to deploy the VM into."
  type        = string
}

variable "service_account_email" {
  description = "The email of the service account to attach to the VM."
  type        = string
}

variable "organization_id" {
  description = "The organization id for the associated services"
}

variable "folder_id" {
  description = "The folder to create projects in"
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
}

variable "tenant_name" {
  description = "Name of tenant for personal environment"
}

variable "region" {
  description = "Name for region"
}

variable "subnetwork" {
  description = "The subnetwork created to host the cluster in"
  default     = "gke-subnet"
}

variable "host_project_id" {
  description = "The host project GCP project ID"
}

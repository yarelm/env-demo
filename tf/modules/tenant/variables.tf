
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

variable "host_project_id" {
  description = "The host project GCP project ID"
}

variable "postgres_ip" {
  description = "The private IP address of postgres DB"
}

variable "subnetwork_uri" {
  description = "The URI of the host subnetwork"
}
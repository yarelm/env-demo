
variable "organization_id" {
  description = "The organization id for the associated services"
}

variable "folder_id" {
  description = "The folder to create projects in"
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
}

variable "host_project_name" {
  description = "Name for Shared VPC host project"
}

variable "network" {
  description = "The VPC network created to host the cluster in"
  default     = "gke-network"
}

variable "region" {
  description = "Name for region"
}

variable "db_zone" {
  description = "Zone name for postgres DB"
}

variable "subnetwork" {
  description = "The subnetwork created to host the cluster in"
  default     = "gke-subnet"
}

variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}

variable "ip_range_services_name" {
  description = "The secondary ip range to use for services"
  default     = "ip-range-scv"
}

variable "cluster_name" {
  description = "The GKE cluster name"
  default     = "host-cluster"
}

variable "tenants" {
  type = list(string)
  description = "list of tenant names"
}
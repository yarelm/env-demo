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
  default     = "shared-vpc-host-multi"
}

variable "region" {
  description = "Name for region"
  default     = "us-west1"
}

variable "gke_zones" {
  type        = list(string)
  description = "The zone to host the cluster in (required if is a zonal cluster)"
  default = ["us-west1-a"]
}

module "host-project" {
  source                         = "terraform-google-modules/project-factory/google"
  random_project_id              = true
  name                           = var.host_project_name
  org_id                         = var.organization_id
  folder_id                      = var.folder_id
  billing_account                = var.billing_account
  enable_shared_vpc_host_project = true

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
  ]
}

data "google_client_config" "default" {}

provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  project_id   = module.host-project.project_id
  network_name = var.network

  subnets = [
    {
      subnet_name           = var.subnetwork
      subnet_ip             = "10.0.0.0/17"
      subnet_region         = var.region
      subnet_private_access = "true"
    },
  ]

  secondary_ranges = {
    "${var.subnetwork}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

data "google_compute_subnetwork" "subnetwork" {
  name       = var.subnetwork
  project    = module.host-project.project_id
  region     = var.region
  depends_on = [module.gcp-network]
}

module "gke" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster/"
  project_id = module.host-project.project_id
  name       = var.cluster_name
  regional   = false
  region     = var.region
  zones      = slice(var.zones, 0, 1)

  network                 = module.gcp-network.network_name
  subnetwork              = module.gcp-network.subnets_names[0]
  ip_range_pods           = var.ip_range_pods_name
  ip_range_services       = var.ip_range_services_name
  create_service_account  = true
  enable_private_endpoint = false
  enable_private_nodes    = true
  master_ipv4_cidr_block  = "172.16.0.0/28"
  grant_registry_access = true

  master_authorized_networks = [
    {
      cidr_block   = data.google_compute_subnetwork.subnetwork.ip_cidr_range
      display_name = "VPC"
    },
    {
      cidr_block   = "77.137.156.108/32"
      display_name = "Terraform execution"
    },
  ]

   node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

}

module "cloud_router" {
  source = "terraform-google-modules/cloud-router/google"

  name    = "gke-router"
  project = module.host-project.project_id
  network = var.network
  region  = var.region

  nats = [{
    name = "gke-nat"
  }]
}
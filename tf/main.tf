

module "developer-1-project" {
  source                         = "terraform-google-modules/project-factory/google"
  random_project_id              = true
  name                           = "dev-david-gke"
  org_id                         = var.organization_id
  folder_id                      = var.folder_id
  billing_account                = var.billing_account
  svpc_host_project_id = module.host-project.project_id
  shared_vpc_subnets = [
    "projects/${module.host-project.project_id}/regions/${var.region}/subnetworks/${var.subnetwork}",
  ]

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
  ]
}

resource "kubernetes_namespace" "developer-1" {
  metadata {
    name = "dev-david-env"
  }
}

module "workload_identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  project_id          = module.host-project.project_id
  name                = "iden-${module.gke.name}"
  namespace           = "dev-david-env"
  use_existing_k8s_sa = false
  depends_on = [
    module.developer-1-project
  ]
}

resource "google_project_iam_binding" "project" {
  project = module.developer-1-project.project_id
  role    = "roles/pubsub.subscriber"

  members = [
    "serviceAccount:${module.workload_identity.gcp_service_account_email}",
  ]
}


module "pubsub" {
  source  = "terraform-google-modules/pubsub/google"
  project_id   = module.developer-1-project.project_id
  topic        = "david-payment-event"

  pull_subscriptions = [
    {
      name                 = "david-payment-event"
      ack_deadline_seconds = 10
    },
  ]
}

/******************************************
  Provider configuration
 *****************************************/
# provider "google" {
#   version = "~> 3.30"
# }

# provider "google-beta" {
#   version = "~> 3.30"
# }

# provider "null" {
#   version = "~> 2.1"
# }

# provider "random" {
#   version = "~> 2.2"
# }

/******************************************
  Host Project Creation
 *****************************************/
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
  # version      = "~> 2.5"
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

/******************************************
  Network Creation
 *****************************************/
# module "vpc" {
#   source  = "terraform-google-modules/network/google"
#   version = "~> 2.5.0"

#   project_id                             = module.host-project.project_id
#   network_name                           = var.network_name
#   delete_default_internet_gateway_routes = true

#   subnets = [
#     {
#       subnet_name   = local.subnet_01
#       subnet_ip     = "10.0.0.0/17"
#       subnet_region = "us-west1"
#       subnet_private_access = true
#     }
#   ]

#   secondary_ranges = {
#     "${local.subnet_01}" = [
#       {
#         range_name    = "${local.subnet_01}-01"
#         ip_cidr_range = "192.168.0.0/18"
#       },
#       {
#         range_name    = "${local.subnet_01}-02"
#         ip_cidr_range = "192.168.64.0/18"
#       },
#     ]
#   }
# }

# data "google_compute_subnetwork" "subnetwork" {
#   name       = local.subnet_01
#   project    = module.host-project.project_id
#   region     = "us-west1"
#   depends_on = [module.vpc]
# }

# module "gcp-network" {
#   source       = "terraform-google-modules/network/google"
#   version      = "~> 2.5"
#   project_id   = module.host-project.project_id
#   network_name = var.network_name

#   subnets = [
#     {
#       subnet_name           = var.subnetwork_name
#       subnet_ip             = "10.0.0.0/17"
#       subnet_region         = var.region
#       subnet_private_access = "true"
#     },
#   ]

#   secondary_ranges = {
#     "${var.subnetwork}" = [
#       {
#         range_name    = var.ip_range_pods_name
#         ip_cidr_range = "192.168.0.0/18"
#       },
#       {
#         range_name    = var.ip_range_services_name
#         ip_cidr_range = "192.168.64.0/18"
#       },
#     ]
#   }
# }

# data "google_compute_subnetwork" "subnetwork" {
#   name       = var.subnetwork_name
#   project    = module.host-project.project_id
#   region     = var.region
#   depends_on = [module.gcp-network]
# }


# /******************************************
#   Service Project Creation
#  *****************************************/
# # module "service-project" {
# #   source = "../../modules/svpc_service_project"

# #   name              = var.service_project_name
# #   random_project_id = "false"

# #   org_id          = var.organization_id
# #   folder_id       = var.folder_id
# #   billing_account = var.billing_account

# #   shared_vpc         = module.host-project.project_id
# #   shared_vpc_subnets = module.vpc.subnets_self_links

# #   activate_apis = [
# #     "compute.googleapis.com",
# #     "container.googleapis.com",
# #     "dataproc.googleapis.com",  
# #     "dataflow.googleapis.com",
# #   ]

# #   disable_services_on_destroy = "false"
# # }



# # google_client_config and kubernetes provider must be explicitly specified like the following.
# data "google_client_config" "default" {}

# provider "kubernetes" {
#   load_config_file       = false
#   host                   = "https://${module.gke.endpoint}"
#   token                  = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(module.gke.ca_certificate)
# }

# module "gke" {
#   source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
#   project_id                 = module.host-project.project_id
#   name                       = "gke-test-11"


#   regional                = false
#   create_service_account  = true
#   enable_private_endpoint = true
#   enable_private_nodes    = true
#   master_ipv4_cidr_block  = "172.16.0.0/28"
#   initial_node_count = 1

#   master_authorized_networks = [
#     {
#       cidr_block   = data.google_compute_subnetwork.subnetwork.ip_cidr_range
#       display_name = "VPC"
#     },
#   ]


#   region                     = var.region
#   zones                      = ["us-west1-a"]
#   network                 = module.gcp-network.network_name
#   subnetwork              = module.gcp-network.subnets_names[0]
#   ip_range_pods           = var.ip_range_pods_name
#   ip_range_services       = var.ip_range_services_name

# }



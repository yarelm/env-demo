module "tenant-project" {
  source                         = "terraform-google-modules/project-factory/google//modules/svpc_service_project"
  random_project_id              = true
  name                           = "${var.tenant_name}-env"
  org_id                         = var.organization_id
  folder_id                      = var.folder_id
  billing_account                = var.billing_account
  shared_vpc = var.host_project_id
  shared_vpc_subnets = [
    "projects/${var.host_project_id}/regions/${var.region}/subnetworks/${var.subnetwork}"
  ]

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
  ]
}

locals {
    k8s_tenant_namespace = "${var.tenant_name}-env"
}

resource "kubernetes_namespace" "tenant" {
  metadata {
    name = local.k8s_tenant_namespace
  }
}

resource "kubernetes_service_account" "ksa" {
  metadata {
    name = "ksa"
    namespace = local.k8s_tenant_namespace

    annotations = {
      "iam.gke.io/gcp-service-account" = module.workload_identity.gcp_service_account_email
    }
  }
}

module "workload_identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  project_id          = var.host_project_id
  name                = "${var.tenant_name}-sa"
  namespace           = local.k8s_tenant_namespace
  k8s_sa_name = "ksa"
  annotate_k8s_sa = false
  use_existing_k8s_sa = true
  depends_on = [
    module.tenant-project,
    kubernetes_namespace.tenant
  ]
}

resource "google_project_iam_binding" "project" {
  project = module.tenant-project.project_id
  role    = "roles/pubsub.subscriber"

  members = [
    "serviceAccount:${module.workload_identity.gcp_service_account_email}",
  ]
}

module "pubsub" {
    source = "../pubsub"
    project_id = module.tenant-project.project_id
}

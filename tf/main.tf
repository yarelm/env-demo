module "host" {
  source = "./modules/host"

  billing_account = var.billing_account
  folder_id = var.folder_id
  organization_id = var.organization_id
  host_project_name = var.host_project_name
  tenants = var.tenants
  region = var.region
  db_zone = var.db_zone
}

data "google_client_config" "default" {}

provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${module.host.kubernetes_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.host.kubernetes_ca_cert)
}

module "dev_envs" {
  source = "./modules/tenant"

  for_each = toset(var.tenants)
  billing_account = var.billing_account
  tenant_name = each.key
  folder_id = var.folder_id
  host_project_id = module.host.host_project_id
  organization_id = var.organization_id
  postgres_ip = module.host.postgres_ip
  subnetwork_uri = module.host.subnetwork_uri
  region = var.region
}

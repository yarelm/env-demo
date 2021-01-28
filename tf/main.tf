locals {
  tenants = ["moshe", "simon"]
}

module "host" {
  source = "./modules/host"

  billing_account = var.billing_account
  folder_id = var.folder_id
  organization_id = var.organization_id
  host_project_name = var.host_project_name
  tenants = local.tenants

  region = var.region
  zones = var.gke_zones
}




module "dev_envs" {
  source = "./modules/developer"
  for_each = toset(local.tenants)
  billing_account = var.billing_account
  developer_name = each.key
  folder_id = var.folder_id
  host_project_id = module.host.host_project_id
  organization_id = var.organization_id

  region = var.region
}
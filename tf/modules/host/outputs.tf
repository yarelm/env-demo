output "host_project_id" {
  value       = module.host-project.project_id
  description = "The ID of the created project"
}

output "kubernetes_endpoint" {
  sensitive = true
  value     = module.gke.endpoint
}

output "kubernetes_ca_cert" {
  sensitive = true
  value     = module.gke.ca_certificate
}